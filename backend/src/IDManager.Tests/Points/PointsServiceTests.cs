using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Points;
using Xunit;

namespace IDManager.Tests.Points;

public class PointsServiceTests
{
    private static UserEntity NewUser(UserRole role, int points = 0, bool isActive = true) => new()
    {
        Name = $"{role} user",
        Phone = Guid.NewGuid().ToString("N")[..10],
        PasswordHash = "hash",
        Role = role,
        Points = points,
        IsActive = isActive,
    };

    [Fact]
    public async Task AdjustPointsAsync_Increase_SuperAdminRequester_DoesNotSpendOwnBalance()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin, points: 0);
        var distributor = NewUser(UserRole.Distributor, points: 0);
        db.Users.AddRange(superAdmin, distributor);
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
        Assert.Equal(0, superAdmin.Points); // SuperAdmin's pool is unlimited - never debited.
    }

    [Fact]
    public async Task AdjustPointsAsync_Increase_NonSuperAdminRequester_SpendsOwnBalance()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var admin = NewUser(UserRole.Admin, points: 100);
        var user = NewUser(UserRole.User, points: 0);
        db.Users.AddRange(admin, user);
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
        var admin = NewUser(UserRole.Admin, points: 10);
        var user = NewUser(UserRole.User, points: 0);
        db.Users.AddRange(admin, user);
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
    public async Task AdjustPointsAsync_SelfAdjust_ReturnsInvalid()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin, points: 0);
        db.Users.Add(superAdmin);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var result = await service.AdjustPointsAsync(
            superAdmin.Id,
            new AdjustPointsRequest { UserId = superAdmin.Id, Points = 10, Reason = "test" },
            increase: true,
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
    }

    [Fact]
    public async Task AdjustPointsAsync_TargetNotActive_ReturnsInvalid()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var superAdmin = NewUser(UserRole.SuperAdmin);
        var inactiveUser = NewUser(UserRole.User, isActive: false);
        db.Users.AddRange(superAdmin, inactiveUser);
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
        db.Users.AddRange(superAdmin, user);
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
    public async Task AdjustPointsAsync_Decrease_CreditsBackToRequester()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var admin = NewUser(UserRole.Admin, points: 0);
        var user = NewUser(UserRole.User, points: 40);
        db.Users.AddRange(admin, user);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var result = await service.AdjustPointsAsync(
            admin.Id,
            new AdjustPointsRequest { UserId = user.Id, Points = 15, Reason = "reclaim" },
            increase: false,
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.Equal(25, user.Points);
        Assert.Equal(15, admin.Points);
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
    public async Task CreateIdCardAsync_CreatesCardAndPendingTransactionsForUserAndCreator()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var admin = NewUser(UserRole.Admin);
        db.Users.Add(admin);
        await db.SaveChangesAsync();
        var user = NewUser(UserRole.User);
        user.CreatedById = admin.Id;
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var service = new PointsService(db);
        var card = new IDCardEntity { UserId = user.Id, TemplateId = 1, PointsDeducted = 3 };
        var cardId = await service.CreateIdCardAsync(card, "Test Member", CancellationToken.None);

        Assert.True(cardId > 0);
        var transactions = db.PointTransactions.Where(t => t.ForIdCardId == cardId).ToList();
        Assert.Equal(2, transactions.Count);
        Assert.Contains(transactions, t => t.UserId == user.Id && t.Type == PointTransType.SpendForCard && t.Status == PointStatus.Pending);
        Assert.Contains(transactions, t => t.UserId == admin.Id && t.Type == PointTransType.EarnForCard && t.Status == PointStatus.Pending);
    }

    [Fact]
    public async Task CompletePaymentTransactionAsync_AppliesBalancesAndMarksCompleted()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var admin = NewUser(UserRole.Admin, points: 10);
        db.Users.Add(admin);
        await db.SaveChangesAsync();
        var user = NewUser(UserRole.User, points: 5);
        user.CreatedById = admin.Id; // CreateIdCardAsync credits the card's *creator*, found via this link.
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
        var page = await service.GetAllAsync(
            new GetPointsRequest { UserId = user.Id, IncludeIncompleteAlso = false, PageIndex = 1, PageSize = 20 },
            CancellationToken.None);

        Assert.Single(page.Items);
        Assert.Equal("a", page.Items[0].Description);
    }
}
