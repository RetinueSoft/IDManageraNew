using IDManager.Api.Domain.Entities;
using IDManager.Api.Domain.Enums;
using IDManager.Api.Dtos;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Api.Persistence.Services;

public class UserPointService : IUserPointService
{
    private readonly ApplicationDbContext _db;

    public UserPointService(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<int> GetUserPointsAsync(int userId)
    {
        var user = await _db.Users.FindAsync(userId) ?? throw new ArgumentException("User not found.");
        return user.Points;
    }

    public async Task<PagedResult<PointTransactionDto>> GetAllAsync(int userId, bool includeIncompleteAlso, PagedRequest request)
    {
        var query = _db.PointTransactions
            .Where(t => t.UserId == userId && (includeIncompleteAlso || t.Status == PointStatus.Completed))
            .OrderByDescending(t => t.CreatedAt);

        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((request.PageIndex - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(t => new PointTransactionDto
            {
                Date = t.CreatedAt,
                Description = t.Reason,
                Points = t.Points * ((t.Type == PointTransType.Spend || t.Type == PointTransType.SpendForCard) ? -1 : 1),
                Type = t.Type,
                Status = t.Status
            })
            .ToListAsync();

        return new PagedResult<PointTransactionDto>
        {
            Items = items,
            TotalCount = totalCount,
            PageIndex = request.PageIndex,
            PageSize = request.PageSize
        };
    }

    // A distributor gives points to (or reclaims points from) a user beneath them,
    // spending/earning their own balance in the opposite direction. SuperAdmin has an
    // unlimited pool and doesn't spend its own balance.
    public async Task<int> AdjustPointsAsync(int requestedById, AdjustPointsRequest request, bool increase)
    {
        var requester = await _db.Users.FindAsync(requestedById)
            ?? throw new ArgumentException("Requesting user not found.");
        var target = await _db.Users.FindAsync(request.UserId)
            ?? throw new ArgumentException("Target user not found.");

        if (!target.Status)
            throw new InvalidOperationException("Target user is not active.");

        if (target.Role != UserRole.SuperAdmin && requester.Id == target.Id)
            throw new InvalidOperationException("Cannot adjust your own points.");

        if (increase && target.Role != UserRole.SuperAdmin && requester.Points < request.Points)
            throw new InvalidOperationException("You do not have enough points.");

        if (!increase && target.Points < request.Points)
            throw new InvalidOperationException("Target does not have enough points to deduct.");

        await using var transaction = await _db.Database.BeginTransactionAsync();

        var delta = increase ? request.Points : -request.Points;
        target.Points += delta;
        _db.PointTransactions.Add(new PointTransaction
        {
            ByUserId = requestedById,
            Points = request.Points,
            Reason = request.Reason,
            Type = increase ? PointTransType.Earn : PointTransType.Spend,
            UserId = target.Id,
            Status = PointStatus.Completed
        });

        if (target.Role != UserRole.SuperAdmin)
        {
            requester.Points -= delta;
            _db.PointTransactions.Add(new PointTransaction
            {
                ByUserId = requestedById,
                Points = request.Points,
                Reason = request.Reason,
                Type = increase ? PointTransType.Spend : PointTransType.Earn,
                UserId = requester.Id,
                Status = PointStatus.Completed
            });
        }

        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        return target.Points;
    }

    public async Task<int> CreateIdCardAsync(IDCard idCard, string forName)
    {
        var user = await _db.Users.FindAsync(idCard.UserId) ?? throw new ArgumentException("User not found.");
        var adminId = user.CreatedById ?? user.Id;

        await using var transaction = await _db.Database.BeginTransactionAsync();

        _db.IDCards.Add(idCard);
        await _db.SaveChangesAsync();

        _db.PointTransactions.Add(new PointTransaction
        {
            ByUserId = idCard.UserId,
            UserId = idCard.UserId,
            Points = idCard.PointsDeducted,
            Reason = $"Card generated for {forName}",
            Type = PointTransType.SpendForCard,
            Status = PointStatus.Pending,
            ForIdCardId = idCard.Id
        });

        _db.PointTransactions.Add(new PointTransaction
        {
            ByUserId = idCard.UserId,
            UserId = adminId,
            Points = idCard.PointsDeducted,
            Reason = $"Card generated by {user.Name} for {forName}",
            Type = PointTransType.EarnForCard,
            Status = PointStatus.Pending,
            ForIdCardId = idCard.Id
        });

        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        return idCard.Id;
    }

    public async Task CompletePaymentTransactionAsync(int idCardId)
    {
        var transactions = await _db.PointTransactions.Where(t => t.ForIdCardId == idCardId).ToListAsync();
        if (transactions.Count == 0)
            throw new ArgumentException("Invalid card id, cannot complete transaction.");

        await using var dbTransaction = await _db.Database.BeginTransactionAsync();

        foreach (var item in transactions)
        {
            var user = await _db.Users.FindAsync(item.UserId);
            if (user == null) continue;

            var sign = (item.Type == PointTransType.Spend || item.Type == PointTransType.SpendForCard) ? -1 : 1;
            user.Points += item.Points * sign;

            if (item.Status == PointStatus.Pending)
                item.Status = PointStatus.Completed;
        }

        await _db.SaveChangesAsync();
        await dbTransaction.CommitAsync();
    }
}
