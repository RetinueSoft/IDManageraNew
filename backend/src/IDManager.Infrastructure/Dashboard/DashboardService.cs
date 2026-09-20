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

        var visible = (await _hierarchy.GetVisibleMembersAsync(user, ct)).Select(m => m.Id);
        var cards = db.IDCards.Where(c => c.GeneratedPdf != null && visible.Contains(c.UserId));

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
            MembersCount = MemberHierarchyService.CanManageMembers(user.Role)
                ? await visible.CountAsync(id => id != userId, ct)
                : null,
            Months = months,
        });
    }
}
