using IDManager.Domain.Enums;
using IDManager.Infrastructure.Members;
using Xunit;

namespace IDManager.Tests.Members;

/// The rules in docs/member-hierarchy.md.
public class MemberHierarchyServiceTests
{
    [Theory]
    // SuperAdmin and Distributor can add Distributor, Retailer, User.
    [InlineData(UserRole.SuperAdmin, UserRole.Distributor, true)]
    [InlineData(UserRole.SuperAdmin, UserRole.Retailer, true)]
    [InlineData(UserRole.SuperAdmin, UserRole.User, true)]
    [InlineData(UserRole.Distributor, UserRole.Distributor, true)]
    [InlineData(UserRole.Distributor, UserRole.Retailer, true)]
    [InlineData(UserRole.Distributor, UserRole.User, true)]
    // A Retailer can add only Retailer and User.
    [InlineData(UserRole.Retailer, UserRole.Retailer, true)]
    [InlineData(UserRole.Retailer, UserRole.User, true)]
    [InlineData(UserRole.Retailer, UserRole.Distributor, false)]
    // Nobody adds a SuperAdmin, and a User adds nobody.
    [InlineData(UserRole.SuperAdmin, UserRole.SuperAdmin, false)]
    [InlineData(UserRole.Distributor, UserRole.SuperAdmin, false)]
    [InlineData(UserRole.Retailer, UserRole.SuperAdmin, false)]
    [InlineData(UserRole.User, UserRole.User, false)]
    [InlineData(UserRole.User, UserRole.Retailer, false)]
    [InlineData(UserRole.User, UserRole.Distributor, false)]
    [InlineData(UserRole.Unknown, UserRole.User, false)]
    public void CanCreate_FollowsTheMemberTable(UserRole creator, UserRole target, bool expected) =>
        Assert.Equal(expected, MemberHierarchyService.CanCreate(creator, target));

    [Theory]
    [InlineData(UserRole.SuperAdmin, true)]
    [InlineData(UserRole.Distributor, true)]
    [InlineData(UserRole.Retailer, true)]
    [InlineData(UserRole.User, false)]
    [InlineData(UserRole.Unknown, false)]
    public void CanManageMembers_OnlyForRolesWithMemberScreens(UserRole role, bool expected) =>
        Assert.Equal(expected, MemberHierarchyService.CanManageMembers(role));

    private static async Task<HashSet<string>> VisibleNamesAsync(TestDb testDb, Domain.Entities.UserEntity viewer)
    {
        var hierarchy = new MemberHierarchyService(testDb.Context);
        var visible = await hierarchy.GetVisibleMembersAsync(viewer, CancellationToken.None);
        return visible.Select(u => u.Name).ToHashSet();
    }

    [Fact]
    public async Task SuperAdmin_SeesEveryMember_IncludingThemselves()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var d1 = await TestUsers.AddAsync(db, "D1", UserRole.Distributor, sa);
        var r1 = await TestUsers.AddAsync(db, "R1", UserRole.Retailer, d1);
        await TestUsers.AddAsync(db, "U1", UserRole.User, r1);
        await TestUsers.AddAsync(db, "Stray", UserRole.User);

        Assert.Equal(new[] { "D1", "R1", "SA", "Stray", "U1" }, (await VisibleNamesAsync(testDb, sa)).Order().ToArray());
    }

    [Fact]
    public async Task Distributor_SeesTheirWholeBranchAtAnyDepth_ButNotOtherBranchesOrTheirUpline()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var d1 = await TestUsers.AddAsync(db, "D1", UserRole.Distributor, sa);
        var r1 = await TestUsers.AddAsync(db, "R1", UserRole.Retailer, d1);
        var r2 = await TestUsers.AddAsync(db, "R2", UserRole.Retailer, r1);   // depth 2
        await TestUsers.AddAsync(db, "U1", UserRole.User, r2);                 // depth 3
        var d2 = await TestUsers.AddAsync(db, "D2", UserRole.Distributor, d1); // a sub-distributor
        await TestUsers.AddAsync(db, "U2", UserRole.User, d2);
        var otherD = await TestUsers.AddAsync(db, "OtherD", UserRole.Distributor, sa);
        await TestUsers.AddAsync(db, "OtherU", UserRole.User, otherD);

        var visible = await VisibleNamesAsync(testDb, d1);

        Assert.Equal(new[] { "D1", "D2", "R1", "R2", "U1", "U2" }, visible.Order().ToArray());
        Assert.DoesNotContain("SA", visible);
        Assert.DoesNotContain("OtherD", visible);
        Assert.DoesNotContain("OtherU", visible);
    }

    [Fact]
    public async Task Retailer_SeesOnlyTheirImmediateChildren()
    {
        // A creates B, B creates C (all retailers), and A also creates a user.
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var a = await TestUsers.AddAsync(db, "A", UserRole.Retailer);
        var b = await TestUsers.AddAsync(db, "B", UserRole.Retailer, a);
        await TestUsers.AddAsync(db, "C", UserRole.Retailer, b);
        await TestUsers.AddAsync(db, "UserOfA", UserRole.User, a);

        // A sees B (and their own user) but not C.
        Assert.Equal(new[] { "A", "B", "UserOfA" }, (await VisibleNamesAsync(testDb, a)).Order().ToArray());
        // B sees C, and not A - nobody sees their upline.
        var visibleToB = await VisibleNamesAsync(testDb, b);
        Assert.Equal(new[] { "B", "C" }, visibleToB.Order().ToArray());
        Assert.DoesNotContain("A", visibleToB);
    }

    [Fact]
    public async Task User_SeesOnlyThemselves()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var r = await TestUsers.AddAsync(db, "R", UserRole.Retailer);
        var u = await TestUsers.AddAsync(db, "U", UserRole.User, r);
        await TestUsers.AddAsync(db, "Sibling", UserRole.User, r);

        Assert.Equal(new[] { "U" }, (await VisibleNamesAsync(testDb, u)).ToArray());
    }

    [Fact]
    public async Task CanManage_IsTrueForVisibleMembersOtherThanSelf()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var a = await TestUsers.AddAsync(db, "A", UserRole.Retailer);
        var b = await TestUsers.AddAsync(db, "B", UserRole.Retailer, a);
        var c = await TestUsers.AddAsync(db, "C", UserRole.Retailer, b);
        var hierarchy = new MemberHierarchyService(db);

        Assert.True(await hierarchy.CanManageAsync(a, b.Id, CancellationToken.None));
        Assert.False(await hierarchy.CanManageAsync(a, c.Id, CancellationToken.None)); // two levels down
        Assert.False(await hierarchy.CanManageAsync(b, a.Id, CancellationToken.None)); // upline
        Assert.False(await hierarchy.CanManageAsync(a, a.Id, CancellationToken.None)); // themselves
    }

    [Fact]
    public async Task CanManage_IsFalseForAUser()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var u = await TestUsers.AddAsync(db, "U", UserRole.User);
        var hierarchy = new MemberHierarchyService(db);

        Assert.False(await hierarchy.CanManageAsync(u, 12345, CancellationToken.None));
    }
}
