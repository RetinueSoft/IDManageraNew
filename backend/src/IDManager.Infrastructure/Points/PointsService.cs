using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Members;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure.Points;

/// Points. Whose points a caller may see or change is decided by MemberHierarchyService
/// (docs/member-hierarchy.md) - this class only applies it.
public class PointsService(IDManagerDbContext db)
{
    private readonly MemberHierarchyService _hierarchy = new(db);

    public async Task<int> GetUserPointsAsync(int userId, CancellationToken ct)
    {
        var user = await db.Users.FindAsync([userId], ct);
        return user?.Points ?? 0;
    }

    /// A member's points history: the caller's own, or a member they can see. Anyone
    /// else's is reported as not found.
    public async Task<OperationResult<PagedResult<PointTransactionDto>>> GetAllAsync(
        int requestedById, GetPointsRequest request, CancellationToken ct)
    {
        var requester = await db.Users.FindAsync([requestedById], ct);
        if (requester is null || !await _hierarchy.CanViewAsync(requester, request.UserId, ct))
        {
            return OperationResult<PagedResult<PointTransactionDto>>.NotFound("User not found.");
        }

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

        return OperationResult<PagedResult<PointTransactionDto>>.Success(new PagedResult<PointTransactionDto>
        {
            Items = items,
            TotalCount = totalCount,
            PageIndex = request.PageIndex,
            PageSize = request.PageSize,
        });
    }

    /// Moves points between members (docs/member-hierarchy.md, section 5). Allocating
    /// debits the caller and credits the target; reclaiming debits the target and credits
    /// the caller. That holds for the SuperAdmin too: their balance is debited when they
    /// allocate. The SuperAdmin is the source of all points, so they alone can add points
    /// to their own balance (top-up); nobody else can adjust their own points.
    ///
    /// Only the SuperAdmin can reclaim points; anyone who manages members can allocate. Allocating
    /// and reclaiming both need a reason, which is what the points history shows for the move (a
    /// top-up may leave it out and is recorded as "Top-up").
    public async Task<OperationResult<int>> AdjustPointsAsync(int requestedById, AdjustPointsRequest request, bool increase, CancellationToken ct)
    {
        if (request.Points <= 0) return OperationResult<int>.Invalid("Points must be greater than zero.");

        var requester = await db.Users.FindAsync([requestedById], ct);
        if (requester is null) return OperationResult<int>.NotFound("Requesting user not found.");
        if (!increase && requester.Role != UserRole.SuperAdmin)
        {
            return OperationResult<int>.Forbidden("Only a Super Admin can reclaim points.");
        }

        var target = await db.Users.FindAsync([request.UserId], ct);
        if (target is null) return OperationResult<int>.NotFound("Target user not found.");

        if (requester.Id == target.Id)
        {
            if (requester.Role == UserRole.SuperAdmin && increase) return await TopUpAsync(requester, request, ct);
            return OperationResult<int>.Invalid("Cannot adjust your own points.");
        }
        var reason = request.Reason?.Trim() ?? "";
        if (reason.Length == 0)
        {
            return OperationResult<int>.Invalid(new Dictionary<string, string> { ["reason"] = "A reason is required." });
        }
        if (!MemberHierarchyService.CanAllocatePointsTo(requester, target))
        {
            return OperationResult<int>.Forbidden("You can only manage points for your own members.");
        }
        if (!target.IsActive) return OperationResult<int>.Invalid("Target user is not active.");

        // Allocating spends the caller's own balance (the SuperAdmin's included).
        if (increase && requester.Points < request.Points)
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
            Reason = reason,
            Type = increase ? PointTransType.Earn : PointTransType.Spend,
            UserId = target.Id,
            Status = PointStatus.Completed,
        });

        requester.Points -= delta;
        db.PointTransactions.Add(new PointTransactionEntity
        {
            ByUserId = requestedById,
            Points = request.Points,
            Reason = reason,
            Type = increase ? PointTransType.Spend : PointTransType.Earn,
            UserId = requester.Id,
            Status = PointStatus.Completed,
        });

        await db.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);

        return OperationResult<int>.Success(target.Points);
    }

    /// Records a card generation: the points are debited from the generating member and
    /// credited to the SuperAdmin - always the SuperAdmin, not the member's parent - so
    /// the SuperAdmin's balance is the running total of points spent on cards and easy
    /// to verify (docs/member-hierarchy.md, section 5). Both entries stay pending until
    /// the PDF is downloaded (CompletePaymentTransactionAsync).
    /// The SuperAdmin adding points to their own balance - the only way points enter the
    /// system. Recorded as an Earn on themselves so it shows in their history.
    private async Task<OperationResult<int>> TopUpAsync(UserEntity superAdmin, AdjustPointsRequest request, CancellationToken ct)
    {
        superAdmin.Points += request.Points;
        db.PointTransactions.Add(new PointTransactionEntity
        {
            ByUserId = superAdmin.Id,
            UserId = superAdmin.Id,
            Points = request.Points,
            Reason = string.IsNullOrWhiteSpace(request.Reason) ? "Top-up" : request.Reason,
            Type = PointTransType.Earn,
            Status = PointStatus.Completed,
        });
        await db.SaveChangesAsync(ct);
        return OperationResult<int>.Success(superAdmin.Points);
    }

    /// The words a card's points history rows use for the card: what it was generated for.
    private static string SpendReason(string forName) => $"Card generated for {forName}";
    private static string EarnReason(string byUserName, string forName) => $"Card generated by {byUserName} for {forName}";

    /// Renames the card in its points history rows (the spend and the matching earn), e.g. once
    /// the final downloaded file name is known.
    public async Task RenameCardTransactionsAsync(int idCardId, string forName, CancellationToken ct)
    {
        var rows = await db.PointTransactions.Where(t => t.ForIdCardId == idCardId).ToListAsync(ct);
        if (rows.Count == 0) return;

        foreach (var row in rows)
        {
            if (row.Type == PointTransType.SpendForCard)
            {
                row.Reason = SpendReason(forName);
            }
            else if (row.Type == PointTransType.EarnForCard)
            {
                var by = await db.Users.FindAsync([row.ByUserId], ct);
                row.Reason = EarnReason(by?.Name ?? "a member", forName);
            }
        }
        await db.SaveChangesAsync(ct);
    }

    public async Task<int> CreateIdCardAsync(IDCardEntity idCard, string forName, CancellationToken ct)
    {
        var user = await db.Users.FindAsync([idCard.UserId], ct) ?? throw new InvalidOperationException("User not found.");
        var superAdmin = await db.Users
            .Where(u => u.Role == UserRole.SuperAdmin)
            .OrderBy(u => u.Id)
            .FirstOrDefaultAsync(ct);
        var adminId = superAdmin?.Id ?? user.CreatedById ?? user.Id;

        await using var transaction = await db.Database.BeginTransactionAsync(ct);

        db.IDCards.Add(idCard);
        await db.SaveChangesAsync(ct);

        db.PointTransactions.Add(new PointTransactionEntity
        {
            ByUserId = idCard.UserId,
            UserId = idCard.UserId,
            Points = idCard.PointsDeducted,
            Reason = SpendReason(forName),
            Type = PointTransType.SpendForCard,
            Status = PointStatus.Pending,
            ForIdCardId = idCard.Id,
        });

        db.PointTransactions.Add(new PointTransactionEntity
        {
            ByUserId = idCard.UserId,
            UserId = adminId,
            Points = idCard.PointsDeducted,
            Reason = EarnReason(user.Name, forName),
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
