using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Users;
using Xunit;

namespace IDManager.Tests.Users;

public class UserServiceTests
{
    [Fact]
    public async Task CreateAsync_MissingRequiredFields_ReturnsFieldErrors()
    {
        using var testDb = TestDb.Create();
        var service = new UserService(testDb.Context);

        var result = await service.CreateAsync(
            1,
            new CreateUserRequest { Name = "", Phone = "", Password = "", Role = UserRole.User },
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.NotNull(result.FieldErrors);
        Assert.Contains("name", result.FieldErrors!.Keys);
        Assert.Contains("phone", result.FieldErrors.Keys);
        Assert.Contains("password", result.FieldErrors.Keys);
    }

    [Fact]
    public async Task CreateAsync_DuplicatePhone_ReturnsValidationError()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        db.Users.Add(new UserEntity { Name = "Existing", Phone = "9123456780", PasswordHash = "x", Role = UserRole.User });
        await db.SaveChangesAsync();

        var service = new UserService(db);
        var result = await service.CreateAsync(
            1,
            new CreateUserRequest { Name = "New Guy", Phone = "9123456780", Password = "Pass@123", Role = UserRole.User },
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Contains("phone", result.FieldErrors!.Keys);
    }

    [Fact]
    public async Task CreateAsync_Valid_PersistsHashedPasswordAndCreator()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var admin = new UserEntity { Name = "Admin", Phone = "9000000001", PasswordHash = "x", Role = UserRole.Admin };
        db.Users.Add(admin);
        await db.SaveChangesAsync();

        var service = new UserService(db);
        var result = await service.CreateAsync(
            admin.Id,
            new CreateUserRequest { Name = "New Distributor", Phone = "9000000002", Password = "Pass@123", Role = UserRole.Distributor },
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        var stored = db.Users.Single(u => u.Phone == "9000000002");
        Assert.Equal(admin.Id, stored.CreatedById);
        Assert.NotEqual("Pass@123", stored.PasswordHash);
        Assert.True(IDManager.Infrastructure.Security.PasswordHasher.Verify("Pass@123", stored.PasswordHash));
    }

    [Fact]
    public async Task GetAllAsync_Distributor_SeesOnlyUsersTheyCreated()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var distributorA = new UserEntity { Name = "Dist A", Phone = "9100000001", PasswordHash = "x", Role = UserRole.Distributor };
        var distributorB = new UserEntity { Name = "Dist B", Phone = "9100000002", PasswordHash = "x", Role = UserRole.Distributor };
        db.Users.AddRange(distributorA, distributorB);
        await db.SaveChangesAsync();

        db.Users.AddRange(
            new UserEntity { Name = "A's user", Phone = "9100000003", PasswordHash = "x", Role = UserRole.User, CreatedById = distributorA.Id },
            new UserEntity { Name = "B's user", Phone = "9100000004", PasswordHash = "x", Role = UserRole.User, CreatedById = distributorB.Id });
        await db.SaveChangesAsync();

        var service = new UserService(db);
        var page = await service.GetAllAsync(distributorA.Id, new PagedRequest { PageIndex = 1, PageSize = 20 }, CancellationToken.None);

        Assert.Single(page.Items);
        Assert.Equal("A's user", page.Items[0].Name);
    }

    [Fact]
    public async Task GetAllAsync_ExcludesRequestingUserFromResults()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var admin = new UserEntity { Name = "Admin", Phone = "9200000001", PasswordHash = "x", Role = UserRole.Admin };
        var other = new UserEntity { Name = "Other", Phone = "9200000002", PasswordHash = "x", Role = UserRole.User };
        db.Users.AddRange(admin, other);
        await db.SaveChangesAsync();

        var service = new UserService(db);
        var page = await service.GetAllAsync(admin.Id, new PagedRequest { PageIndex = 1, PageSize = 20 }, CancellationToken.None);

        Assert.DoesNotContain(page.Items, u => u.Id == admin.Id);
        Assert.Contains(page.Items, u => u.Id == other.Id);
    }

    [Fact]
    public async Task DeactivateAsync_NotFound_ReturnsNotFound()
    {
        using var testDb = TestDb.Create();
        var service = new UserService(testDb.Context);

        var result = await service.DeactivateAsync(999_999, CancellationToken.None);

        Assert.Equal(ResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task DeactivateAsync_SetsIsActiveFalse()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var user = new UserEntity { Name = "Someone", Phone = "9300000001", PasswordHash = "x", Role = UserRole.User, IsActive = true };
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var service = new UserService(db);
        var result = await service.DeactivateAsync(user.Id, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.False(user.IsActive);
    }
}
