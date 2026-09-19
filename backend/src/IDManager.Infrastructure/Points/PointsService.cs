using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure.Points;

public class PointsService(IDManagerDbContext db)
{
    public async Task<int> GetUserPointsAsync(int userId, CancellationToken ct)
    {
        var user = await db.Users.FindAsync([userId], ct);
        return user?.Points ?? 0;
    }

    public async Task<PagedResult<PointTransactionDto>> GetAllAsync(GetPointsRequest request, CancellationToken ct)
    {
        var query = db.PointTransactions
            .Where(t => t.UserId == request.UserId && (request.IncludeIncompleteAlso || t.Status == PointStatus.Completed))
            .OrderByDescending(t => t.CreatedAt);

        var totalCount = await query.CountAsync(ct);
        var items = await query
            .Skip((request.PageIndex - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(t => new PointTransactionDto
            {
                Date = t.CreatedAt,
                Description = t.Reason,
                Points = t.Points * ((t.Type == PointTransType.Spend || t.Type == PointTransType.SpendForCard) ? -1 : 1),
                Type = t.Type,
                Status = t.Status,
            })
            .ToListAsync(ct);

        return new PagedResult<PointTransactionDto>
        {
            Items = items,
            TotalCount = totalCount,
            PageIndex = request.PageIndex,
            PageSize = request.PageSize,
        };
    }

    /// A distributor gives points to (or reclaims points from) a user beneath them,
    /// spending/earning their own balance in the opposite direction. SuperAdmin has
    /// an unlimited pool and doesn't spend its own balance.
    public async Task<OperationResult<int>> AdjustPointsAsync(int requestedById, AdjustPointsRequest request, bool increase, CancellationToken ct)
    {
        var requester = await db.Users.FindAsync([requestedById], ct);
        if (requester is null) return OperationResult<int>.NotFound("Requesting user not found.");

        var target = await db.Users.FindAsync([request.UserId], ct);
        if (target is null) return OperationResult<int>.NotFound("Target user not found.");

        if (!target.IsActive) return OperationResult<int>.Invalid("Target user is not active.");
        if (requester.Id == target.Id)
        {
            return OperationResult<int>.Invalid("Cannot adjust your own points.");
        }

        // SuperAdmin is the platform's point source - it hands out an unlimited
        // pool and never spends its own balance. Everyone else redistributes from
        // (or back into) their own balance in the opposite direction.
        var requesterIsUnlimited = requester.Role == UserRole.SuperAdmin;
        if (increase && !requesterIsUnlimited && requester.Points < request.Points)
        {
            return OperationResult<int>.Invalid("You do not have enough points.");
        }
        if (!increase && target.Points < request.Points)
        {
            return OperationResult<int>.Invalid("Target does not have enough points to deduct.");
        }

        await using var transaction = await db.Database.BeginTransactionAsync(ct);

        var delta = increase ? request.Points : -request.Points;
        target.Points += delta;
        db.PointTransactions.Add(new PointTransactionEntity
        {
            ByUserId = requestedById,
            Points = request.Points,
            Reason = request.Reason,
            Type = increase ? PointTransType.Earn : PointTransType.Spend,
            UserId = target.Id,
            Status = PointStatus.Completed,
        });

        if (!requesterIsUnlimited)
        {
            requester.Points -= delta;
            db.PointTransactions.Add(new PointTransactionEntity
            {
                ByUserId = requestedById,
                Points = request.Points,
                Reason = request.Reason,
                Type = increase ? PointTransType.Spend : PointTransType.Earn,
                UserId = requester.Id,
                Status = PointStatus.Completed,
            });
        }

        await db.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);

        return OperationResult<int>.Success(target.Points);
    }

    public async Task<int> CreateIdCardAsync(IDCardEntity idCard, string forName, CancellationToken ct)
    {
        var user = await db.Users.FindAsync([idCard.UserId], ct) ?? throw new InvalidOperationException("User not found.");
        var adminId = user.CreatedById ?? user.Id;

        await using var transaction = await db.Database.BeginTransactionAsync(ct);

        db.IDCards.Add(idCard);
        await db.SaveChangesAsync(ct);

        db.PointTransactions.Add(new PointTransactionEntity
        {
            ByUserId = idCard.UserId,
            UserId = idCard.UserId,
            Points = idCard.PointsDeducted,
            Reason = $"Card generated for {forName}",
            Type = PointTransType.SpendForCard,
            Status = PointStatus.Pending,
            ForIdCardId = idCard.Id,
        });

        db.PointTransactions.Add(new PointTransactionEntity
        {
            ByUserId = idCard.UserId,
            UserId = adminId,
            Points = idCard.PointsDeducted,
            Reason = $"Card generated by {user.Name} for {forName}",
            Type = PointTransType.EarnForCard,
            Status = PointStatus.Pending,
            ForIdCardId = idCard.Id,
        });

        await db.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);

        return idCard.Id;
    }

    public async Task CompletePaymentTransactionAsync(int idCardId, CancellationToken ct)
    {
        var transactions = await db.PointTransactions.Where(t => t.ForIdCardId == idCardId).ToListAsync(ct);
        if (transactions.Count == 0) return;

        await using var dbTransaction = await db.Database.BeginTransactionAsync(ct);

        foreach (var item in transactions)
        {
            var user = await db.Users.FindAsync([item.UserId], ct);
            if (user is null) continue;

            var sign = (item.Type == PointTransType.Spend || item.Type == PointTransType.SpendForCard) ? -1 : 1;
            user.Points += item.Points * sign;

            if (item.Status == PointStatus.Pending) item.Status = PointStatus.Completed;
        }

        await db.SaveChangesAsync(ct);
        await dbTransaction.CommitAsync(ct);
    }
}
