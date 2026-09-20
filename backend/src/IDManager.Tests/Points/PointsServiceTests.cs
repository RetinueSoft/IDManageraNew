using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Points;
using Xunit;

namespace IDManager.Tests.Points;

public class PointsServiceTests
{
    private static UserEntity NewUser(UserRole role, int points = 0, bool isActive = true, UserEntity? parent = null) => new()
    {
        Name = $"{role} user",
        Phone = Guid.NewGuid().ToString("N")[..10],
        PasswordHash = "hash",
        Role = role,
        Points = points,
        IsActive = isActive,
        CreatedById = parent?.Id,
    };

    [Fact]
    public async Task AdjustPointsAsync_Increase_SuperAdminRequester_DebitsTheirOwnBalance()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin, points: 100);
        var distributor = NewUser(UserRole.Distributor, points: 0);
        db.Users.Add(superAdmin);
        await db.SaveChangesAsync();
        distributor.CreatedById = superAdmin.Id; // the SuperAdmin's own member
        db.Users.Add(distributor);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var result = await service.AdjustPointsAsync(
            superAdmin.Id,
            new AdjustPointsRequest { UserId = distributor.Id, Points = 50, Reason = "seed" },
            increase: true,
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.Equal(50, result.Value);
        Assert.Equal(50, distributor.Points);
        Assert.Equal(50, superAdmin.Points); // 100 - 50: the SuperAdmin's balance is debited like anyone's.
        Assert.Equal(2, db.PointTransactions.Count()); // one leg for the member, one for the SuperAdmin
    }

    [Fact]
    public async Task AdjustPointsAsync_Increase_NonSuperAdminRequester_SpendsOwnBalance()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var admin = NewUser(UserRole.Distributor, points: 100);
        db.Users.Add(admin);
        await db.SaveChangesAsync();
        var user = NewUser(UserRole.User, points: 0, parent: admin);
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var result = await service.AdjustPointsAsync(
            admin.Id,
            new AdjustPointsRequest { UserId = user.Id, Points = 30, Reason = "allocate" },
            increase: true,
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.Equal(30, user.Points);
        Assert.Equal(70, admin.Points);
    }

    [Fact]
    public async Task AdjustPointsAsync_Increase_NonSuperAdminRequester_InsufficientBalance_ReturnsInvalid()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var admin = NewUser(UserRole.Distributor, points: 10);
        db.Users.Add(admin);
        await db.SaveChangesAsync();
        var user = NewUser(UserRole.User, points: 0, parent: admin);
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var result = await service.AdjustPointsAsync(
            admin.Id,
            new AdjustPointsRequest { UserId = user.Id, Points = 30, Reason = "allocate" },
            increase: true,
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Equal(0, user.Points);
        Assert.Equal(10, admin.Points);
    }

    [Fact]
    public async Task AdjustPointsAsync_NonSuperAdmin_CannotAdjustTheirOwnPoints()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var distributor = NewUser(UserRole.Distributor, points: 100);
        db.Users.Add(distributor);
        await db.SaveChangesAsync();

        var result = await new PointsService(db).AdjustPointsAsync(
            distributor.Id,
            new AdjustPointsRequest { UserId = distributor.Id, Points = 10, Reason = "test" },
            increase: true,
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Equal(100, distributor.Points);
    }

    [Fact]
    public async Task AdjustPointsAsync_SuperAdmin_CanTopUpTheirOwnBalance()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin, points: 0);
        db.Users.Add(superAdmin);
        await db.SaveChangesAsync();

        var result = await new PointsService(db).AdjustPointsAsync(
            superAdmin.Id,
            new AdjustPointsRequest { UserId = superAdmin.Id, Points = 1000, Reason = "initial stock" },
            increase: true,
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.Equal(1000, result.Value);
        Assert.Equal(1000, superAdmin.Points);
        var entry = Assert.Single(db.PointTransactions);
        Assert.Equal(PointTransType.Earn, entry.Type);
        Assert.Equal(superAdmin.Id, entry.UserId);
    }

    [Fact]
    public async Task AdjustPointsAsync_SuperAdmin_CannotDeductFromTheirOwnBalance()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin, points: 100);
        db.Users.Add(superAdmin);
        await db.SaveChangesAsync();

        var result = await new PointsService(db).AdjustPointsAsync(
            superAdmin.Id,
            new AdjustPointsRequest { UserId = superAdmin.Id, Points = 10, Reason = "test" },
            increase: false,
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Equal(100, superAdmin.Points);
    }

    [Fact]
    public async Task AdjustPointsAsync_SuperAdminWithInsufficientBalance_CannotAllocate()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin, points: 5);
        var distributor = NewUser(UserRole.Distributor);
        db.Users.Add(superAdmin);
        await db.SaveChangesAsync();
        distributor.CreatedById = superAdmin.Id; // the SuperAdmin's own member
        db.Users.Add(distributor);
        await db.SaveChangesAsync();

        var result = await new PointsService(db).AdjustPointsAsync(
            superAdmin.Id,
            new AdjustPointsRequest { UserId = distributor.Id, Points = 10, Reason = "x" },
            increase: true,
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Equal(0, distributor.Points);
        Assert.Equal(5, superAdmin.Points);
    }

    [Fact]
    public async Task AdjustPointsAsync_SuperAdminReclaim_CreditsTheirBalance()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin, points: 0);
        var distributor = NewUser(UserRole.Distributor, points: 40);
        db.Users.Add(superAdmin);
        await db.SaveChangesAsync();
        distributor.CreatedById = superAdmin.Id; // the SuperAdmin's own member
        db.Users.Add(distributor);
        await db.SaveChangesAsync();

        var result = await new PointsService(db).AdjustPointsAsync(
            superAdmin.Id,
            new AdjustPointsRequest { UserId = distributor.Id, Points = 15, Reason = "reclaim" },
            increase: false,
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.Equal(25, distributor.Points);
        Assert.Equal(15, superAdmin.Points);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-5)]
    public async Task AdjustPointsAsync_NonPositivePoints_IsInvalid(int points)
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin, points: 100);
        var distributor = NewUser(UserRole.Distributor);
        db.Users.Add(superAdmin);
        await db.SaveChangesAsync();
        distributor.CreatedById = superAdmin.Id; // the SuperAdmin's own member
        db.Users.Add(distributor);
        await db.SaveChangesAsync();

        var result = await new PointsService(db).AdjustPointsAsync(
            superAdmin.Id,
            new AdjustPointsRequest { UserId = distributor.Id, Points = points, Reason = "x" },
            increase: true,
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Equal(100, superAdmin.Points);
    }

    [Fact]
    public async Task AdjustPointsAsync_TargetNotActive_ReturnsInvalid()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin);
        var inactiveUser = NewUser(UserRole.User, isActive: false);
        db.Users.Add(superAdmin);
        await db.SaveChangesAsync();
        inactiveUser.CreatedById = superAdmin.Id; // the SuperAdmin's own member
        db.Users.Add(inactiveUser);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var result = await service.AdjustPointsAsync(
            superAdmin.Id,
            new AdjustPointsRequest { UserId = inactiveUser.Id, Points = 10, Reason = "test" },
            increase: true,
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
    }

    [Fact]
    public async Task AdjustPointsAsync_Decrease_InsufficientTargetBalance_ReturnsInvalid()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin);
        var user = NewUser(UserRole.User, points: 5);
        db.Users.Add(superAdmin);
        await db.SaveChangesAsync();
        user.CreatedById = superAdmin.Id; // the SuperAdmin's own member
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var result = await service.AdjustPointsAsync(
            superAdmin.Id,
            new AdjustPointsRequest { UserId = user.Id, Points = 10, Reason = "reclaim" },
            increase: false,
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Equal(5, user.Points);
    }

    [Fact]
    public async Task AdjustPointsAsync_Decrease_ByAMemberWhoIsNotTheSuperAdmin_IsForbidden()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var admin = NewUser(UserRole.Distributor, points: 0);
        db.Users.Add(admin);
        await db.SaveChangesAsync();
        var user = NewUser(UserRole.User, points: 40, parent: admin);
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var result = await service.AdjustPointsAsync(
            admin.Id,
            new AdjustPointsRequest { UserId = user.Id, Points = 15, Reason = "reclaim" },
            increase: false,
            CancellationToken.None);

        Assert.Equal(ResultStatus.Forbidden, result.Status);
        Assert.Equal(40, user.Points);
        Assert.Equal(0, admin.Points);
        Assert.Empty(db.PointTransactions);
    }

    [Theory]
    [InlineData(UserRole.Distributor)]
    [InlineData(UserRole.Retailer)]
    [InlineData(UserRole.User)]
    public async Task AdjustPointsAsync_OnlyTheSuperAdminMayReclaim(UserRole role)
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var member = await TestUsers.AddAsync(db, "M", role, sa, points: 20);
        var child = await TestUsers.AddAsync(db, "C", UserRole.User, member, points: 20);

        var result = await new PointsService(db).AdjustPointsAsync(
            member.Id, new AdjustPointsRequest { UserId = child.Id, Points = 5, Reason = "take back" }, increase: false, CancellationToken.None);

        Assert.Equal(ResultStatus.Forbidden, result.Status);
        Assert.Equal(20, child.Points);
        Assert.Equal(20, member.Points);
    }

    [Theory]
    [InlineData(UserRole.Distributor)]
    [InlineData(UserRole.Retailer)]
    public async Task AdjustPointsAsync_TheseRolesCanStillAllocate(UserRole role)
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var member = await TestUsers.AddAsync(db, "M", role, sa, points: 20);
        var child = await TestUsers.AddAsync(db, "C", UserRole.User, member, points: 0);

        var result = await new PointsService(db).AdjustPointsAsync(
            member.Id, new AdjustPointsRequest { UserId = child.Id, Points = 5, Reason = "start-up points" }, increase: true, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.Equal(5, child.Points);
        Assert.Equal(15, member.Points);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    public async Task AdjustPointsAsync_AllocatingNeedsAReason(string? reason)
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin, points: 100);
        var member = await TestUsers.AddAsync(db, "M", UserRole.Retailer, sa);

        var result = await new PointsService(db).AdjustPointsAsync(
            sa.Id, new AdjustPointsRequest { UserId = member.Id, Points = 10, Reason = reason! }, increase: true, CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Contains("reason", result.FieldErrors!.Keys);
        Assert.Equal(0, member.Points);
        Assert.Equal(100, sa.Points);
        Assert.Empty(db.PointTransactions);
    }

    [Fact]
    public async Task AdjustPointsAsync_ReclaimingNeedsAReasonToo()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var member = await TestUsers.AddAsync(db, "M", UserRole.Retailer, sa, points: 30);

        var result = await new PointsService(db).AdjustPointsAsync(
            sa.Id, new AdjustPointsRequest { UserId = member.Id, Points = 10, Reason = " " }, increase: false, CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Contains("reason", result.FieldErrors!.Keys);
        Assert.Equal(30, member.Points);
    }

    [Fact]
    public async Task AdjustPointsAsync_TheReasonIsTrimmedAndShownInBothHistories()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin, points: 100);
        var member = await TestUsers.AddAsync(db, "M", UserRole.Retailer, sa);

        await new PointsService(db).AdjustPointsAsync(
            sa.Id, new AdjustPointsRequest { UserId = member.Id, Points = 10, Reason = "  Diwali offer \n" }, increase: true, CancellationToken.None);

        Assert.All(db.PointTransactions, t => Assert.Equal("Diwali offer", t.Reason));
        Assert.Equal(2, db.PointTransactions.Count());
    }

    [Fact]
    public async Task AdjustPointsAsync_ASuperAdminTopUpNeedsNoReason()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin, points: 0);

        var result = await new PointsService(db).AdjustPointsAsync(
            sa.Id, new AdjustPointsRequest { UserId = sa.Id, Points = 500, Reason = "" }, increase: true, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.Equal(500, sa.Points);
        Assert.Equal("Top-up", db.PointTransactions.Single().Reason);
    }

    [Fact]
    public async Task AdjustPointsAsync_TargetNotFound_ReturnsNotFound()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin);
        db.Users.Add(superAdmin);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var result = await service.AdjustPointsAsync(
            superAdmin.Id,
            new AdjustPointsRequest { UserId = 999_999, Points = 10, Reason = "test" },
            increase: true,
            CancellationToken.None);

        Assert.Equal(ResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task CreateIdCardAsync_CreatesCardAndPendingTransactionsForUserAndSuperAdmin()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var admin = NewUser(UserRole.SuperAdmin);
        db.Users.Add(admin);
        await db.SaveChangesAsync();
        var distributor = NewUser(UserRole.Distributor, parent: admin);
        db.Users.Add(distributor);
        await db.SaveChangesAsync();
        var user = NewUser(UserRole.User, parent: distributor);
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var card = new IDCardEntity { UserId = user.Id, TemplateId = 1, PointsDeducted = 3 };
        var cardId = await service.CreateIdCardAsync(card, "Test Member", CancellationToken.None);

        Assert.True(cardId > 0);
        var transactions = db.PointTransactions.Where(t => t.ForIdCardId == cardId).ToList();
        Assert.Equal(2, transactions.Count);
        Assert.Contains(transactions, t => t.UserId == user.Id && t.Type == PointTransType.SpendForCard && t.Status == PointStatus.Pending);
        // Credited to the SuperAdmin - not to the member's parent (the distributor).
        Assert.Contains(transactions, t => t.UserId == admin.Id && t.Type == PointTransType.EarnForCard && t.Status == PointStatus.Pending);
        Assert.DoesNotContain(transactions, t => t.UserId == distributor.Id);
    }

    [Fact]
    public async Task CompletePaymentTransactionAsync_AppliesBalancesAndMarksCompleted()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var admin = NewUser(UserRole.SuperAdmin, points: 10);
        db.Users.Add(admin);
        await db.SaveChangesAsync();
        var user = NewUser(UserRole.User, points: 5); // any member: the credit always goes to the SuperAdmin
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var card = new IDCardEntity { UserId = user.Id, TemplateId = 1, PointsDeducted = 2 };
        var cardId = await service.CreateIdCardAsync(card, "Test Member", CancellationToken.None);

        // CreateIdCardAsync only records the pending transactions - it doesn't
        // touch balances yet, so they should be unchanged until payment completes.
        Assert.Equal(5, user.Points);
        Assert.Equal(10, admin.Points);

        await service.CompletePaymentTransactionAsync(cardId, CancellationToken.None);

        Assert.Equal(3, user.Points); // 5 - 2 (SpendForCard)
        Assert.Equal(12, admin.Points); // 10 + 2 (EarnForCard)
        Assert.All(
            db.PointTransactions.Where(t => t.ForIdCardId == cardId),
            t => Assert.Equal(PointStatus.Completed, t.Status));
    }

    [Fact]
    public async Task GetAllAsync_ExcludesIncompleteTransactionsByDefault()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var user = NewUser(UserRole.User);
        db.Users.Add(user);
        await db.SaveChangesAsync();
        db.PointTransactions.AddRange(
            new PointTransactionEntity { UserId = user.Id, Points = 5, Type = PointTransType.Earn, Status = PointStatus.Completed, Reason = "a" },
            new PointTransactionEntity { UserId = user.Id, Points = 5, Type = PointTransType.SpendForCard, Status = PointStatus.Pending, Reason = "b" });
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var result = await service.GetAllAsync(
            user.Id,
            new GetPointsRequest { UserId = user.Id, IncludeIncompleteAlso = false, PageIndex = 1, PageSize = 20 },
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        var page = result.Value!;
        Assert.Single(page.Items);
        Assert.Equal("a", page.Items[0].Description);
    }

    // ---- who can see / change whose points (docs/member-hierarchy.md) ----

    [Fact]
    public async Task AdjustPointsAsync_MemberOutsideTheCallersNetwork_IsForbidden()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var d1 = await TestUsers.AddAsync(db, "D1", UserRole.Distributor, points: 100);
        var d2 = await TestUsers.AddAsync(db, "D2", UserRole.Distributor);
        var d2User = await TestUsers.AddAsync(db, "D2 user", UserRole.User, d2);

        var result = await new PointsService(db).AdjustPointsAsync(
            d1.Id, new AdjustPointsRequest { UserId = d2User.Id, Points = 10, Reason = "x" }, increase: true, CancellationToken.None);

        Assert.Equal(ResultStatus.Forbidden, result.Status);
        Assert.Equal(0, d2User.Points);
        Assert.Equal(100, d1.Points);
    }

    [Fact]
    public async Task AdjustPointsAsync_Distributor_OnlyReachesTheirOwnMembers_NotDeeperInTheBranch()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var d = await TestUsers.AddAsync(db, "D", UserRole.Distributor, points: 100);
        var r = await TestUsers.AddAsync(db, "R", UserRole.Retailer, d);
        var u = await TestUsers.AddAsync(db, "U", UserRole.User, r);
        var service = new PointsService(db);

        var own = await service.AdjustPointsAsync(
            d.Id, new AdjustPointsRequest { UserId = r.Id, Points = 10, Reason = "x" }, increase: true, CancellationToken.None);
        var deeper = await service.AdjustPointsAsync(
            d.Id, new AdjustPointsRequest { UserId = u.Id, Points = 10, Reason = "x" }, increase: true, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, own.Status);
        Assert.Equal(ResultStatus.Forbidden, deeper.Status); // U belongs to R, not to D
        Assert.Equal(0, u.Points);
    }

    [Fact]
    public async Task AdjustPointsAsync_SuperAdmin_OnlyReachesTheirOwnMembers()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin, points: 100);
        var d = await TestUsers.AddAsync(db, "D", UserRole.Distributor, sa);
        var deeper = await TestUsers.AddAsync(db, "Deeper", UserRole.User, d);
        var service = new PointsService(db);

        var own = await service.AdjustPointsAsync(
            sa.Id, new AdjustPointsRequest { UserId = d.Id, Points = 10, Reason = "x" }, increase: true, CancellationToken.None);
        var notOwn = await service.AdjustPointsAsync(
            sa.Id, new AdjustPointsRequest { UserId = deeper.Id, Points = 10, Reason = "x" }, increase: true, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, own.Status);
        Assert.Equal(ResultStatus.Forbidden, notOwn.Status);
    }

    [Fact]
    public async Task AdjustPointsAsync_Retailer_OnlyReachesImmediateChildren()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var a = await TestUsers.AddAsync(db, "A", UserRole.Retailer, points: 100);
        var b = await TestUsers.AddAsync(db, "B", UserRole.Retailer, a);
        var c = await TestUsers.AddAsync(db, "C", UserRole.Retailer, b);
        var service = new PointsService(db);

        var child = await service.AdjustPointsAsync(
            a.Id, new AdjustPointsRequest { UserId = b.Id, Points = 10, Reason = "x" }, increase: true, CancellationToken.None);
        var grandchild = await service.AdjustPointsAsync(
            a.Id, new AdjustPointsRequest { UserId = c.Id, Points = 10, Reason = "x" }, increase: true, CancellationToken.None);
        var upline = await service.AdjustPointsAsync(
            b.Id, new AdjustPointsRequest { UserId = a.Id, Points = 1, Reason = "x" }, increase: true, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, child.Status);
        Assert.Equal(ResultStatus.Forbidden, grandchild.Status);
        Assert.Equal(ResultStatus.Forbidden, upline.Status);
        Assert.Equal(0, c.Points);
    }

    [Fact]
    public async Task AdjustPointsAsync_AUserCannotAdjustAnyonesPoints()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var u = await TestUsers.AddAsync(db, "U", UserRole.User, points: 50);
        var other = await TestUsers.AddAsync(db, "Other", UserRole.User);

        var result = await new PointsService(db).AdjustPointsAsync(
            u.Id, new AdjustPointsRequest { UserId = other.Id, Points = 5, Reason = "x" }, increase: true, CancellationToken.None);

        Assert.Equal(ResultStatus.Forbidden, result.Status);
    }

    [Fact]
    public async Task GetAllAsync_HistoryOfAMemberOutsideTheNetwork_IsNotFound()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var d1 = await TestUsers.AddAsync(db, "D1", UserRole.Distributor);
        var d2 = await TestUsers.AddAsync(db, "D2", UserRole.Distributor);
        var mine = await TestUsers.AddAsync(db, "Mine", UserRole.User, d1);
        var service = new PointsService(db);

        var own = await service.GetAllAsync(d1.Id, new GetPointsRequest { UserId = mine.Id, PageIndex = 1, PageSize = 10 }, CancellationToken.None);
        var stranger = await service.GetAllAsync(d1.Id, new GetPointsRequest { UserId = d2.Id, PageIndex = 1, PageSize = 10 }, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, own.Status);
        Assert.Equal(ResultStatus.NotFound, stranger.Status);
    }
}
