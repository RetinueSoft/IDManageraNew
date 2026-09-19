using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure;
using IDManager.Infrastructure.Users;
using Xunit;

namespace IDManager.Tests.Users;

public class UserServiceTests
{
    private static readonly PagedRequest FirstPage = new() { PageIndex = 1, PageSize = 50 };

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
    public async Task CreateAsync_Valid_PersistsHashedPasswordAndCreatorAsParent()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);

        var service = new UserService(db);
        var result = await service.CreateAsync(
            sa.Id,
            new CreateUserRequest { Name = "New Distributor", Phone = "9000000002", Password = "Pass@123", Role = UserRole.Distributor },
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        var stored = db.Users.Single(u => u.Phone == "9000000002");
        Assert.Equal(sa.Id, stored.CreatedById);
        Assert.NotEqual("Pass@123", stored.PasswordHash);
        Assert.True(IDManager.Infrastructure.Security.PasswordHasher.Verify("Pass@123", stored.PasswordHash));
        Assert.Equal("SA", result.Value!.ParentName);
    }

    [Theory]
    [InlineData(UserRole.Retailer, UserRole.Distributor)]   // a Retailer cannot add a Distributor
    [InlineData(UserRole.User, UserRole.User)]              // a User cannot add anyone
    [InlineData(UserRole.Distributor, UserRole.SuperAdmin)] // nobody adds a SuperAdmin
    public async Task CreateAsync_RoleNotAllowedForCreator_IsForbidden(UserRole creatorRole, UserRole targetRole)
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var creator = await TestUsers.AddAsync(db, "Creator", creatorRole);

        var service = new UserService(db);
        var result = await service.CreateAsync(
            creator.Id,
            new CreateUserRequest { Name = "X", Phone = "9555555555", Password = "Pass@123", Role = targetRole },
            CancellationToken.None);

        Assert.Equal(ResultStatus.Forbidden, result.Status);
        Assert.False(db.Users.Any(u => u.Phone == "9555555555"));
    }

    [Fact]
    public async Task GetAllAsync_ListsTheCallersVisibleMembers_WithParents()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var d1 = await TestUsers.AddAsync(db, "D1", UserRole.Distributor, sa);
        var r1 = await TestUsers.AddAsync(db, "R1", UserRole.Retailer, d1);

        var service = new UserService(db);

        // SuperAdmin sees everyone, themselves included, and who each one belongs to.
        var all = (await service.GetAllAsync(sa.Id, FirstPage, CancellationToken.None)).Items;
        Assert.Equal(new[] { "D1", "R1", "SA" }, all.Select(u => u.Name).Order().ToArray());
        Assert.Equal("D1", all.Single(u => u.Name == "R1").ParentName);
        Assert.Equal(UserRole.Distributor, all.Single(u => u.Name == "R1").ParentRole);
        Assert.Equal("SA", all.Single(u => u.Name == "D1").ParentName);
        Assert.Null(all.Single(u => u.Name == "SA").ParentName);

        // A distributor does not see their own upline (the SuperAdmin), even as a parent name.
        var branch = (await service.GetAllAsync(d1.Id, FirstPage, CancellationToken.None)).Items;
        Assert.Equal(new[] { "D1", "R1" }, branch.Select(u => u.Name).Order().ToArray());
        Assert.Null(branch.Single(u => u.Name == "D1").ParentName);
        Assert.Equal("D1", branch.Single(u => u.Name == "R1").ParentName);

        // The retailer sees only themselves (no children), and not the distributor above.
        var retailerView = (await service.GetAllAsync(r1.Id, FirstPage, CancellationToken.None)).Items;
        Assert.Equal(new[] { "R1" }, retailerView.Select(u => u.Name).ToArray());
        Assert.Null(retailerView[0].ParentName);
    }

    [Fact]
    public async Task GetAllAsync_SearchIsAppliedWithinTheVisibleMembers()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        await TestUsers.AddAsync(db, "Alice", UserRole.Distributor, sa);
        await TestUsers.AddAsync(db, "Bob", UserRole.Distributor, sa);

        var page = await new UserService(db).GetAllAsync(
            sa.Id, new PagedRequest { PageIndex = 1, PageSize = 50, SearchBy = "Ali" }, CancellationToken.None);

        Assert.Equal(new[] { "Alice" }, page.Items.Select(u => u.Name).ToArray());
    }

    [Fact]
    public async Task GetByIdAsync_OutsideTheCallersNetwork_IsNotFound()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var a = await TestUsers.AddAsync(db, "A", UserRole.Retailer);
        var b = await TestUsers.AddAsync(db, "B", UserRole.Retailer, a);
        var c = await TestUsers.AddAsync(db, "C", UserRole.Retailer, b);
        var service = new UserService(db);

        Assert.Equal(ResultStatus.Success, (await service.GetByIdAsync(a.Id, b.Id, CancellationToken.None)).Status);
        Assert.Equal(ResultStatus.Success, (await service.GetByIdAsync(a.Id, a.Id, CancellationToken.None)).Status);
        Assert.Equal(ResultStatus.NotFound, (await service.GetByIdAsync(a.Id, c.Id, CancellationToken.None)).Status);
        Assert.Equal(ResultStatus.NotFound, (await service.GetByIdAsync(b.Id, a.Id, CancellationToken.None)).Status);
    }

    [Fact]
    public async Task UpdateAsync_ManagerCanEditAVisibleMember_ButNotOneOutsideTheirNetwork()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var a = await TestUsers.AddAsync(db, "A", UserRole.Retailer);
        var b = await TestUsers.AddAsync(db, "B", UserRole.Retailer, a);
        var c = await TestUsers.AddAsync(db, "C", UserRole.Retailer, b);
        var service = new UserService(db);

        var ok = await service.UpdateAsync(a.Id, new UpdateUserRequest { Id = b.Id, Name = "B renamed", IsActive = true }, CancellationToken.None);
        var outside = await service.UpdateAsync(a.Id, new UpdateUserRequest { Id = c.Id, Name = "hacked", IsActive = true }, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, ok.Status);
        Assert.Equal("B renamed", b.Name);
        Assert.Equal(ResultStatus.NotFound, outside.Status);
        Assert.Equal("C", c.Name);
    }

    [Fact]
    public async Task UpdateAsync_YouCanRenameYourself_ButNotDeactivateYourself()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var service = new UserService(db);

        var rename = await service.UpdateAsync(sa.Id, new UpdateUserRequest { Id = sa.Id, Name = "Boss", IsActive = true }, CancellationToken.None);
        var deactivate = await service.UpdateAsync(sa.Id, new UpdateUserRequest { Id = sa.Id, Name = "Boss", IsActive = false }, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, rename.Status);
        Assert.Equal(ResultStatus.ValidationFailed, deactivate.Status);
        Assert.True(sa.IsActive);
    }

    [Fact]
    public async Task DeactivateAsync_NotFound_ReturnsNotFound()
    {
        using var testDb = TestDb.Create();
        var sa = await TestUsers.AddAsync(testDb.Context, "SA", UserRole.SuperAdmin);
        var service = new UserService(testDb.Context);

        var result = await service.DeactivateAsync(sa.Id, 999_999, CancellationToken.None);

        Assert.Equal(ResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task DeactivateAsync_SuperAdminCanDeactivateAnyMember()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var d = await TestUsers.AddAsync(db, "D", UserRole.Distributor, sa);
        var deep = await TestUsers.AddAsync(db, "Deep", UserRole.User, d);

        var result = await new UserService(db).DeactivateAsync(sa.Id, deep.Id, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.False(deep.IsActive);
    }

    [Theory]
    [InlineData(UserRole.Distributor)]
    [InlineData(UserRole.Retailer)]
    [InlineData(UserRole.User)]
    public async Task DeactivateAsync_OnlyASuperAdminMay(UserRole callerRole)
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var caller = await TestUsers.AddAsync(db, "Caller", callerRole);
        var member = await TestUsers.AddAsync(db, "Member", UserRole.User, caller);

        var result = await new UserService(db).DeactivateAsync(caller.Id, member.Id, CancellationToken.None);

        Assert.Equal(ResultStatus.Forbidden, result.Status);
        Assert.True(member.IsActive);
    }

    [Fact]
    public async Task DeactivateAsync_SuperAdminCannotDeactivateThemselves()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);

        var result = await new UserService(db).DeactivateAsync(sa.Id, sa.Id, CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.True(sa.IsActive);
    }

    // ---- password and active status (docs/member-hierarchy.md, section 4) ----

    private static async Task<(UserEntity sa, UserEntity distributor, UserEntity member)> TreeAsync(IDManagerDbContext db)
    {
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var distributor = await TestUsers.AddAsync(db, "D", UserRole.Distributor, sa);
        var member = await TestUsers.AddAsync(db, "Member", UserRole.User, distributor);
        return (sa, distributor, member);
    }

    [Fact]
    public async Task UpdateAsync_ChangingAMembersPassword_IsForbiddenForTheirManager_ButNotForSuperAdmin()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (sa, distributor, member) = await TreeAsync(db);
        var service = new UserService(db);
        var before = member.PasswordHash;

        var byManager = await service.UpdateAsync(distributor.Id,
            new UpdateUserRequest { Id = member.Id, Name = "Member", IsActive = true, Password = "NewPass@1" }, CancellationToken.None);
        Assert.Equal(ResultStatus.Forbidden, byManager.Status);
        Assert.Equal(before, member.PasswordHash);

        var bySuperAdmin = await service.UpdateAsync(sa.Id,
            new UpdateUserRequest { Id = member.Id, Name = "Member", IsActive = true, Password = "NewPass@1" }, CancellationToken.None);
        Assert.Equal(ResultStatus.Success, bySuperAdmin.Status);
        Assert.NotEqual(before, member.PasswordHash);
    }

    [Fact]
    public async Task UpdateAsync_AMemberCanChangeTheirOwnPassword()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (_, distributor, _) = await TreeAsync(db);
        var before = distributor.PasswordHash;

        var result = await new UserService(db).UpdateAsync(distributor.Id,
            new UpdateUserRequest { Id = distributor.Id, Name = "D", IsActive = true, Password = "Mine@123" }, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.NotEqual(before, distributor.PasswordHash);
    }

    [Fact]
    public async Task UpdateAsync_ManagerCanStillRenameAMember_WithoutTouchingThePassword()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (_, distributor, member) = await TreeAsync(db);

        var result = await new UserService(db).UpdateAsync(distributor.Id,
            new UpdateUserRequest { Id = member.Id, Name = "Renamed", IsActive = true }, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.Equal("Renamed", member.Name);
    }

    [Fact]
    public async Task UpdateAsync_ActivatingOrDeactivating_IsForbiddenForTheirManager_ButNotForSuperAdmin()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (sa, distributor, member) = await TreeAsync(db);
        var service = new UserService(db);

        var byManager = await service.UpdateAsync(distributor.Id,
            new UpdateUserRequest { Id = member.Id, Name = "Member", IsActive = false }, CancellationToken.None);
        Assert.Equal(ResultStatus.Forbidden, byManager.Status);
        Assert.True(member.IsActive);

        var deactivate = await service.UpdateAsync(sa.Id,
            new UpdateUserRequest { Id = member.Id, Name = "Member", IsActive = false }, CancellationToken.None);
        Assert.Equal(ResultStatus.Success, deactivate.Status);
        Assert.False(member.IsActive);

        var activate = await service.UpdateAsync(sa.Id,
            new UpdateUserRequest { Id = member.Id, Name = "Member", IsActive = true }, CancellationToken.None);
        Assert.Equal(ResultStatus.Success, activate.Status);
        Assert.True(member.IsActive);
    }
}
