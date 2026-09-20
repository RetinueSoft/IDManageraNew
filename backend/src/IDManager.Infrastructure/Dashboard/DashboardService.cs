using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Members;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure.Dashboard;

/// The numbers on the dashboard. Points are the signed-in member's own (their own history, as on the
/// Points screen); card and member counts follow who they can see (docs/member-hierarchy.md,
/// section 3), through MemberHierarchyService.
public class DashboardService(IDManagerDbContext db)
{
    /// How many calendar months the month-wise graphs cover, the current one included.
    public const int MonthsShown = 12;

    private readonly MemberHierarchyService _hierarchy = new(db);

    private static bool IsCredit(PointTransType type) => type is PointTransType.Earn or PointTransType.EarnForCard;

    public async Task<OperationResult<DashboardSummaryDto>> GetSummaryAsync(int userId, CancellationToken ct, DateTime? nowUtc = null)
    {
        var user = await db.Users.FindAsync([userId], ct);
        if (user is null) return OperationResult<DashboardSummaryDto>.NotFound("User not found.");

        var now = nowUtc ?? DateTime.UtcNow;
        var thisMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var windowStart = thisMonth.AddMonths(-(MonthsShown - 1));

        // Only points that were applied count; a card's are pending until its PDF is downloaded.
        var own = db.PointTransactions.Where(t => t.UserId == userId && t.Status == PointStatus.Completed);
        var rows = await own
            .Where(t => t.CreatedAt >= windowStart)
            .Select(t => new { t.Type, t.Points, t.CreatedAt })
            .ToListAsync(ct);

        var months = new List<MonthlyPointsDto>();
        for (var i = 0; i < MonthsShown; i++)
        {
            var month = windowStart.AddMonths(i);
            var inMonth = rows.Where(r => r.CreatedAt.Year == month.Year && r.CreatedAt.Month == month.Month).ToList();
            months.Add(new MonthlyPointsDto
            {
                Year = month.Year,
                Month = month.Month,
                Credit = inMonth.Where(r => IsCredit(r.Type)).Sum(r => r.Points),
                Debit = inMonth.Where(r => !IsCredit(r.Type)).Sum(r => r.Points),
            });
        }

        var creditTotal = await own.Where(t => t.Type == PointTransType.Earn || t.Type == PointTransType.EarnForCard).SumAsync(t => (int?)t.Points, ct) ?? 0;
        var debitTotal = await own.Where(t => t.Type == PointTransType.Spend || t.Type == PointTransType.SpendForCard).SumAsync(t => (int?)t.Points, ct) ?? 0;

        var visibleMembers = await _hierarchy.GetVisibleMembersAsync(user, ct);
        var visible = visibleMembers.Select(m => m.Id);
        // Every card generated - previewed or downloaded. The Super Admin sees everyone, so theirs is the whole app.
        var cards = db.IDCards.Where(c => visible.Contains(c.UserId));

        // Members: everyone they can see, except themselves and any Super Admin - for the Super Admin that
        // is every member of the whole app - counted by role. Nobody without member screens has any.
        MemberRoleCountsDto? members = null;
        if (MemberHierarchyService.CanManageMembers(user.Role))
        {
            var roles = await visibleMembers
                .Where(m => m.Id != userId && m.Role != UserRole.SuperAdmin)
                .GroupBy(m => m.Role)
                .Select(g => new { Role = g.Key, Count = g.Count() })
                .ToListAsync(ct);
            int Of(UserRole role) => roles.FirstOrDefault(r => r.Role == role)?.Count ?? 0;
            members = new MemberRoleCountsDto
            {
                Distributors = Of(UserRole.Distributor),
                Retailers = Of(UserRole.Retailer),
                Users = Of(UserRole.User),
            };
        }

        var current = months[^1];
        return OperationResult<DashboardSummaryDto>.Success(new DashboardSummaryDto
        {
            Balance = user.Points,
            CreditThisMonth = current.Credit,
            DebitThisMonth = current.Debit,
            CreditTotal = creditTotal,
            DebitTotal = debitTotal,
            CardsThisMonth = await cards.CountAsync(c => c.CreatedAt >= thisMonth, ct),
            CardsTotal = await cards.CountAsync(ct),
            MembersCount = members?.Total,
            MembersByRole = members,
            Months = months,
        });
    }
}
