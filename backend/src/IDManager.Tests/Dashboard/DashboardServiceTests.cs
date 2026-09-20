using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure;
using IDManager.Infrastructure.Dashboard;
using Xunit;

namespace IDManager.Tests.Dashboard;

public class DashboardServiceTests
{
    // "Now" for every test: 20 September 2026.
    private static readonly DateTime Now = new(2026, 9, 20, 12, 0, 0, DateTimeKind.Utc);

    private static async Task AddPointsAsync(IDManagerDbContext db, int userId, PointTransType type, int points, DateTime when, PointStatus status = PointStatus.Completed)
    {
        db.PointTransactions.Add(new PointTransactionEntity
        {
            UserId = userId, ByUserId = userId, Type = type, Points = points, Status = status, CreatedAt = when, Reason = "test",
        });
        await db.SaveChangesAsync();
    }

    private static async Task AddCardAsync(IDManagerDbContext db, int userId, DateTime when, bool downloaded = true)
    {
        db.IDCards.Add(new IDCardEntity
        {
            UserId = userId, TemplateId = 1, ExtractedDataJson = "[]", CreatedAt = when,
            GeneratedPdf = downloaded ? [1, 2, 3] : null,
        });
        await db.SaveChangesAsync();
    }

    private static async Task<DashboardSummaryDto> SummaryAsync(IDManagerDbContext db, int userId)
    {
        var result = await new DashboardService(db).GetSummaryAsync(userId, CancellationToken.None, Now);
        Assert.Equal(ResultStatus.Success, result.Status);
        return result.Value!;
    }

    [Fact]
    public async Task UnknownUser_IsNotFound()
    {
        using var testDb = TestDb.Create();

        var result = await new DashboardService(testDb.Context).GetSummaryAsync(999, CancellationToken.None, Now);

        Assert.Equal(ResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task ThereAreTwelveMonths_OldestFirst_EndingWithTheCurrentOne_EvenWithNoActivity()
    {
        using var testDb = TestDb.Create();
        var user = await TestUsers.AddAsync(testDb.Context, "U", UserRole.User);

        var summary = await SummaryAsync(testDb.Context, user.Id);

        Assert.Equal(12, summary.Months.Count);
        Assert.Equal((2025, 10), (summary.Months[0].Year, summary.Months[0].Month));
        Assert.Equal((2026, 9), (summary.Months[^1].Year, summary.Months[^1].Month));
        Assert.All(summary.Months, m => Assert.Equal((0, 0), (m.Credit, m.Debit)));
        // The months run without a gap across the year end.
        Assert.Equal(new[] { 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9 }, summary.Months.Select(m => m.Month));
    }

    [Fact]
    public async Task CreditsAndDebitsAreAddedUpPerMonth()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var user = await TestUsers.AddAsync(db, "U", UserRole.Retailer, points: 50);
        await AddPointsAsync(db, user.Id, PointTransType.Earn, 100, new DateTime(2026, 7, 3, 0, 0, 0, DateTimeKind.Utc));
        await AddPointsAsync(db, user.Id, PointTransType.EarnForCard, 5, new DateTime(2026, 7, 28, 0, 0, 0, DateTimeKind.Utc));
        await AddPointsAsync(db, user.Id, PointTransType.Spend, 30, new DateTime(2026, 7, 10, 0, 0, 0, DateTimeKind.Utc));
        await AddPointsAsync(db, user.Id, PointTransType.SpendForCard, 2, new DateTime(2026, 8, 1, 0, 0, 0, DateTimeKind.Utc));
        await AddPointsAsync(db, user.Id, PointTransType.SpendForCard, 3, new DateTime(2026, 9, 5, 0, 0, 0, DateTimeKind.Utc));

        var summary = await SummaryAsync(db, user.Id);

        var july = summary.Months.Single(m => m.Month == 7);
        Assert.Equal((105, 30), (july.Credit, july.Debit));
        var august = summary.Months.Single(m => m.Month == 8);
        Assert.Equal((0, 2), (august.Credit, august.Debit));
        Assert.Equal(50, summary.Balance);
        Assert.Equal((0, 3), (summary.CreditThisMonth, summary.DebitThisMonth));
        Assert.Equal((105, 35), (summary.CreditTotal, summary.DebitTotal));
    }

    [Fact]
    public async Task OnlyAppliedPointsCount_NotPendingOrFailed()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var user = await TestUsers.AddAsync(db, "U", UserRole.User);
        var when = new DateTime(2026, 9, 2, 0, 0, 0, DateTimeKind.Utc);
        await AddPointsAsync(db, user.Id, PointTransType.SpendForCard, 4, when, PointStatus.Pending);
        await AddPointsAsync(db, user.Id, PointTransType.Earn, 9, when, PointStatus.Failed);
        await AddPointsAsync(db, user.Id, PointTransType.SpendForCard, 1, when);

        var summary = await SummaryAsync(db, user.Id);

        Assert.Equal((0, 1), (summary.CreditThisMonth, summary.DebitThisMonth));
        Assert.Equal((0, 1), (summary.CreditTotal, summary.DebitTotal));
    }

    [Fact]
    public async Task OnlyTheMembersOwnPointsAreCounted()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var me = await TestUsers.AddAsync(db, "Me", UserRole.Retailer);
        var other = await TestUsers.AddAsync(db, "Other", UserRole.Retailer);
        var when = new DateTime(2026, 9, 2, 0, 0, 0, DateTimeKind.Utc);
        await AddPointsAsync(db, me.Id, PointTransType.Earn, 10, when);
        await AddPointsAsync(db, other.Id, PointTransType.Earn, 999, when);

        var summary = await SummaryAsync(db, me.Id);

        Assert.Equal(10, summary.CreditThisMonth);
        Assert.Equal(10, summary.CreditTotal);
    }

    [Fact]
    public async Task ActivityOlderThanTwelveMonthsIsInTheTotalsButNotOnTheGraph()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var user = await TestUsers.AddAsync(db, "U", UserRole.User);
        await AddPointsAsync(db, user.Id, PointTransType.Earn, 40, new DateTime(2025, 9, 30, 0, 0, 0, DateTimeKind.Utc)); // 12 months + 1 day before the window
        await AddPointsAsync(db, user.Id, PointTransType.Earn, 7, new DateTime(2025, 10, 1, 0, 0, 0, DateTimeKind.Utc)); // first day of the window

        var summary = await SummaryAsync(db, user.Id);

        Assert.Equal(47, summary.CreditTotal);
        Assert.Equal(7, summary.Months[0].Credit);
        Assert.Equal(7, summary.Months.Sum(m => m.Credit));
    }

    [Fact]
    public async Task ThisMonthMeansTheCalendarMonth_NotTheLast30Days()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var user = await TestUsers.AddAsync(db, "U", UserRole.User);
        await AddPointsAsync(db, user.Id, PointTransType.Earn, 5, new DateTime(2026, 8, 31, 23, 59, 0, DateTimeKind.Utc)); // 20 days ago but last month
        await AddPointsAsync(db, user.Id, PointTransType.Earn, 8, new DateTime(2026, 9, 1, 0, 0, 0, DateTimeKind.Utc));

        var summary = await SummaryAsync(db, user.Id);

        Assert.Equal(8, summary.CreditThisMonth);
        Assert.Equal(5, summary.Months[^2].Credit);
    }

    // ------------------------------------------------------------------ cards and members

    [Fact]
    public async Task CardsCountEveryCardGenerated_DownloadedOrNot_ThisMonthAndInAll()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var user = await TestUsers.AddAsync(db, "U", UserRole.User);
        await AddCardAsync(db, user.Id, new DateTime(2026, 9, 3, 0, 0, 0, DateTimeKind.Utc));
        await AddCardAsync(db, user.Id, new DateTime(2026, 9, 4, 0, 0, 0, DateTimeKind.Utc));
        await AddCardAsync(db, user.Id, new DateTime(2026, 8, 4, 0, 0, 0, DateTimeKind.Utc));
        await AddCardAsync(db, user.Id, new DateTime(2026, 9, 5, 0, 0, 0, DateTimeKind.Utc), downloaded: false);

        var summary = await SummaryAsync(db, user.Id);

        Assert.Equal(3, summary.CardsThisMonth); // the previewed one counts too
        Assert.Equal(4, summary.CardsTotal);
    }

    [Fact]
    public async Task CardsAndMembersFollowWhoTheMemberCanSee()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var a = await TestUsers.AddAsync(db, "A", UserRole.Retailer, sa);
        var b = await TestUsers.AddAsync(db, "B", UserRole.Retailer, a);
        var c = await TestUsers.AddAsync(db, "C", UserRole.User, b);
        var when = new DateTime(2026, 9, 3, 0, 0, 0, DateTimeKind.Utc);
        await AddCardAsync(db, a.Id, when);
        await AddCardAsync(db, b.Id, when);
        await AddCardAsync(db, b.Id, when);
        await AddCardAsync(db, c.Id, when);

        var forSa = await SummaryAsync(db, sa.Id);
        var forA = await SummaryAsync(db, a.Id);
        var forB = await SummaryAsync(db, b.Id);
        var forC = await SummaryAsync(db, c.Id);

        // The SuperAdmin counts the whole app: every card, and every member but themselves.
        Assert.Equal((4, 3), (forSa.CardsTotal, forSa.MembersCount));
        // A Retailer only themselves and their own members.
        Assert.Equal((3, 1), (forA.CardsTotal, forA.MembersCount));  // A + B (not C)
        Assert.Equal((3, 1), (forB.CardsTotal, forB.MembersCount));  // B + C (not A)
        // A User has no member screens: no member count, and only their own cards.
        Assert.Equal(1, forC.CardsTotal);
        Assert.Null(forC.MembersCount);
    }

    [Fact]
    public async Task ADistributorSeesTheirWholeBranch()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var d = await TestUsers.AddAsync(db, "D", UserRole.Distributor, sa);
        var r = await TestUsers.AddAsync(db, "R", UserRole.Retailer, d);
        var u = await TestUsers.AddAsync(db, "U", UserRole.User, r);
        var outsider = await TestUsers.AddAsync(db, "Outsider", UserRole.Distributor, sa);
        var when = new DateTime(2026, 9, 3, 0, 0, 0, DateTimeKind.Utc);
        await AddCardAsync(db, u.Id, when);
        await AddCardAsync(db, outsider.Id, when);

        var summary = await SummaryAsync(db, d.Id);

        Assert.Equal(2, summary.MembersCount);   // R and U, not the outsider
        Assert.Equal(1, summary.CardsTotal);
    }

    [Fact]
    public async Task TheSuperAdminsCountsCoverTheWholeApp_EvenMembersDeepInTheTree()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var d = await TestUsers.AddAsync(db, "D", UserRole.Distributor, sa);
        var r = await TestUsers.AddAsync(db, "R", UserRole.Retailer, d);
        var u = await TestUsers.AddAsync(db, "U", UserRole.User, r);
        var other = await TestUsers.AddAsync(db, "O", UserRole.Distributor, sa);
        var when = new DateTime(2026, 9, 3, 0, 0, 0, DateTimeKind.Utc);
        foreach (var member in new[] { sa, d, r, u, other })
        {
            await AddCardAsync(db, member.Id, when, downloaded: member.Id % 2 == 0);
        }

        var summary = await SummaryAsync(db, sa.Id);

        Assert.Equal(5, summary.CardsTotal);
        Assert.Equal(5, summary.CardsThisMonth);
        Assert.Equal(4, summary.MembersCount); // everyone but the Super Admin
    }

    [Fact]
    public async Task ADistributorsCountsStayWithTheirBranch()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var d = await TestUsers.AddAsync(db, "D", UserRole.Distributor, sa);
        var r = await TestUsers.AddAsync(db, "R", UserRole.Retailer, d);
        var outsider = await TestUsers.AddAsync(db, "O", UserRole.Distributor, sa);
        var when = new DateTime(2026, 9, 3, 0, 0, 0, DateTimeKind.Utc);
        await AddCardAsync(db, d.Id, when, downloaded: false);
        await AddCardAsync(db, r.Id, when);
        await AddCardAsync(db, outsider.Id, when);

        var summary = await SummaryAsync(db, d.Id);

        Assert.Equal(2, summary.CardsTotal);   // their own and R's, not the outsider's
        Assert.Equal(1, summary.MembersCount); // R
    }

    [Fact]
    public async Task Members_AreCountedByRole_ForTheSuperAdmin_WithoutTheSuperAdmin()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var d1 = await TestUsers.AddAsync(db, "D1", UserRole.Distributor, sa);
        await TestUsers.AddAsync(db, "D2", UserRole.Distributor, sa);
        var r1 = await TestUsers.AddAsync(db, "R1", UserRole.Retailer, d1);
        await TestUsers.AddAsync(db, "R2", UserRole.Retailer, sa);
        await TestUsers.AddAsync(db, "R3", UserRole.Retailer, r1);
        await TestUsers.AddAsync(db, "U1", UserRole.User, r1);
        await TestUsers.AddAsync(db, "U2", UserRole.User, sa);

        var summary = await SummaryAsync(db, sa.Id);

        Assert.Equal((2, 3, 2), (summary.MembersByRole!.Distributors, summary.MembersByRole.Retailers, summary.MembersByRole.Users));
        Assert.Equal(7, summary.MembersCount);
        Assert.Equal(summary.MembersCount, summary.MembersByRole.Total);
    }

    [Fact]
    public async Task Members_ForADistributor_AreTheirBranchByRole()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var d = await TestUsers.AddAsync(db, "D", UserRole.Distributor, sa);
        var r = await TestUsers.AddAsync(db, "R", UserRole.Retailer, d);
        await TestUsers.AddAsync(db, "U", UserRole.User, r);
        var outsider = await TestUsers.AddAsync(db, "O", UserRole.Distributor, sa);
        await TestUsers.AddAsync(db, "OU", UserRole.User, outsider);

        var summary = await SummaryAsync(db, d.Id);

        Assert.Equal((0, 1, 1), (summary.MembersByRole!.Distributors, summary.MembersByRole.Retailers, summary.MembersByRole.Users));
        Assert.Equal(2, summary.MembersCount);
    }

    [Fact]
    public async Task Members_ForAUser_AreNotCountedAtAll()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var u = await TestUsers.AddAsync(db, "U", UserRole.User, sa);

        var summary = await SummaryAsync(db, u.Id);

        Assert.Null(summary.MembersCount);
        Assert.Null(summary.MembersByRole);
    }
}
