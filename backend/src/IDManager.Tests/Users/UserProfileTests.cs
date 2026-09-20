using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Users;
using Xunit;

namespace IDManager.Tests.Users;

/// The optional shop details and identity proof of a member (docs/member-hierarchy.md, section
/// 4a). None of it is required.
public class UserProfileTests
{
    private static readonly byte[] Jpeg = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46];
    private static readonly byte[] Png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00];
    private static readonly byte[] Webp = [(byte)'R', (byte)'I', (byte)'F', (byte)'F', 0, 0, 0, 0, (byte)'W', (byte)'E', (byte)'B', (byte)'P'];

    private static CreateUserRequest NewMember(string phone = "9000000001") => new()
    {
        Name = "Shop Owner", Phone = phone, Password = "Pass@123", Role = UserRole.Retailer,
    };

    // ------------------------------------------------------------------ profile fields

    [Fact]
    public async Task ACollectionOfNoDetailsIsFine_EverythingIsOptional()
    {
        using var testDb = TestDb.Create();
        var sa = await TestUsers.AddAsync(testDb.Context, "SA", UserRole.SuperAdmin);

        var result = await new UserService(testDb.Context).CreateAsync(sa.Id, NewMember(), CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        var member = result.Value!;
        Assert.Null(member.ShopName);
        Assert.Null(member.ShopAddress);
        Assert.Null(member.City);
        Assert.Null(member.Pincode);
        Assert.Null(member.IdType);
        Assert.Null(member.IdNumber);
        Assert.False(member.HasIdFront);
        Assert.False(member.HasIdBack);
    }

    [Fact]
    public async Task TheDetailsAreStoredWhenAMemberIsAdded_TrimmedAndBlankAsNothing()
    {
        using var testDb = TestDb.Create();
        var sa = await TestUsers.AddAsync(testDb.Context, "SA", UserRole.SuperAdmin);
        var request = NewMember();
        request.ShopName = "  Sri Murugan Stores ";
        request.ShopAddress = "12, Main Road\nCoimbatore";
        request.City = "Coimbatore";
        request.Pincode = "   ";
        request.IdType = "Aadhaar";
        request.IdNumber = " 1234 5678 9012 ";

        var result = await new UserService(testDb.Context).CreateAsync(sa.Id, request, CancellationToken.None);

        var member = result.Value!;
        Assert.Equal("Sri Murugan Stores", member.ShopName);
        Assert.Equal("12, Main Road\nCoimbatore", member.ShopAddress);
        Assert.Equal("Coimbatore", member.City);
        Assert.Null(member.Pincode);
        Assert.Equal("Aadhaar", member.IdType);
        Assert.Equal("1234 5678 9012", member.IdNumber);
    }

    [Fact]
    public async Task TheDetailsComeBackWhenTheMemberIsRead_AndInTheList()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var service = new UserService(db);
        var request = NewMember();
        request.ShopName = "Sri Murugan Stores";
        var created = (await service.CreateAsync(sa.Id, request, CancellationToken.None)).Value!;

        var read = (await service.GetByIdAsync(sa.Id, created.Id, CancellationToken.None)).Value!;
        var listed = (await service.GetAllAsync(sa.Id, new PagedRequest { PageIndex = 1, PageSize = 50 }, CancellationToken.None))
            .Items.Single(u => u.Id == created.Id);

        Assert.Equal("Sri Murugan Stores", read.ShopName);
        Assert.Equal("Sri Murugan Stores", listed.ShopName);
    }

    [Fact]
    public async Task UpdatingSetsTheDetails_ANullFieldKeepsTheOldValue_ABlankOneClearsIt()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var service = new UserService(db);
        var request = NewMember();
        request.ShopName = "Old shop";
        request.City = "Old city";
        var created = (await service.CreateAsync(sa.Id, request, CancellationToken.None)).Value!;

        var updated = (await service.UpdateAsync(sa.Id, new UpdateUserRequest
        {
            Id = created.Id, Name = "Shop Owner", IsActive = true,
            ShopName = "New shop",   // changed
            City = null,             // not sent: kept
            Pincode = "641001",      // added
            ShopAddress = "  ",      // blank: nothing stored
        }, CancellationToken.None)).Value!;

        Assert.Equal("New shop", updated.ShopName);
        Assert.Equal("Old city", updated.City);
        Assert.Equal("641001", updated.Pincode);
        Assert.Null(updated.ShopAddress);

        var cleared = (await service.UpdateAsync(sa.Id, new UpdateUserRequest
        {
            Id = created.Id, Name = "Shop Owner", IsActive = true, City = "",
        }, CancellationToken.None)).Value!;
        Assert.Null(cleared.City);
        Assert.Equal("New shop", cleared.ShopName);
    }

    [Fact]
    public async Task TooLongDetailsAreRejectedWithTheFieldName()
    {
        using var testDb = TestDb.Create();
        var sa = await TestUsers.AddAsync(testDb.Context, "SA", UserRole.SuperAdmin);
        var request = NewMember();
        request.ShopName = new string('a', 151);
        request.IdNumber = new string('9', 51);

        var result = await new UserService(testDb.Context).CreateAsync(sa.Id, request, CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Contains("shopName", result.FieldErrors!.Keys);
        Assert.Contains("idNumber", result.FieldErrors.Keys);
        Assert.Empty(testDb.Context.Users.Where(u => u.Phone == request.Phone));
    }

    [Fact]
    public async Task ARetailerCanSetTheDetailsOfAMemberTheyManage_ButNotOfSomeoneOutsideTheirView()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var retailer = await TestUsers.AddAsync(db, "R", UserRole.Retailer, sa);
        var child = await TestUsers.AddAsync(db, "Child", UserRole.User, retailer);
        var stranger = await TestUsers.AddAsync(db, "Stranger", UserRole.User, sa);
        var service = new UserService(db);

        var ok = await service.UpdateAsync(retailer.Id, new UpdateUserRequest { Id = child.Id, Name = "Child", IsActive = true, ShopName = "Kiosk" }, CancellationToken.None);
        var hidden = await service.UpdateAsync(retailer.Id, new UpdateUserRequest { Id = stranger.Id, Name = "Stranger", IsActive = true, ShopName = "Nope" }, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, ok.Status);
        Assert.Equal("Kiosk", ok.Value!.ShopName);
        Assert.Equal(ResultStatus.NotFound, hidden.Status);
        Assert.Null(db.Users.Find(stranger.Id)!.ShopName);
    }

    // ------------------------------------------------------------------ identity images

    private static async Task<(UserService service, IDManager.Infrastructure.IDManagerDbContext db, UserEntity sa, UserEntity member)> MemberAsync(TestDb testDb)
    {
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var member = await TestUsers.AddAsync(db, "Member", UserRole.Retailer, sa);
        return (new UserService(db), db, sa, member);
    }

    [Fact]
    public async Task AnIdentityImageCanBeAddedAndReadBack_WithItsType()
    {
        using var testDb = TestDb.Create();
        var (service, _, sa, member) = await MemberAsync(testDb);

        Assert.Equal(ResultStatus.Success, (await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, Jpeg, CancellationToken.None)).Status);
        Assert.Equal(ResultStatus.Success, (await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Back, Png, CancellationToken.None)).Status);

        var front = (await service.GetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, CancellationToken.None)).Value!;
        var back = (await service.GetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Back, CancellationToken.None)).Value!;
        Assert.Equal(Jpeg, front.Bytes);
        Assert.Equal("image/jpeg", front.ContentType);
        Assert.Equal(Png, back.Bytes);
        Assert.Equal("image/png", back.ContentType);
    }

    [Fact]
    public async Task TheMemberShowsWhichImagesTheyHave_WithoutCarryingThem()
    {
        using var testDb = TestDb.Create();
        var (service, _, sa, member) = await MemberAsync(testDb);
        await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, Webp, CancellationToken.None);

        var read = (await service.GetByIdAsync(sa.Id, member.Id, CancellationToken.None)).Value!;
        var listed = (await service.GetAllAsync(sa.Id, new PagedRequest { PageIndex = 1, PageSize = 50 }, CancellationToken.None))
            .Items.Single(u => u.Id == member.Id);

        Assert.True(read.HasIdFront);
        Assert.False(read.HasIdBack);
        Assert.True(listed.HasIdFront);
        Assert.False(listed.HasIdBack);
        Assert.Equal("image/webp", (await service.GetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, CancellationToken.None)).Value!.ContentType);
    }

    [Fact]
    public async Task ReplacingAnImageKeepsTheOtherSide()
    {
        using var testDb = TestDb.Create();
        var (service, _, sa, member) = await MemberAsync(testDb);
        await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, Jpeg, CancellationToken.None);
        await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Back, Png, CancellationToken.None);

        await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, Webp, CancellationToken.None);

        Assert.Equal(Webp, (await service.GetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, CancellationToken.None)).Value!.Bytes);
        Assert.Equal(Png, (await service.GetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Back, CancellationToken.None)).Value!.Bytes);
    }

    [Fact]
    public async Task AnImageCanBeRemoved_AndTheRowGoesWhenBothAreGone()
    {
        using var testDb = TestDb.Create();
        var (service, db, sa, member) = await MemberAsync(testDb);
        await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, Jpeg, CancellationToken.None);
        await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Back, Png, CancellationToken.None);

        await service.DeleteIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, CancellationToken.None);
        Assert.Equal(ResultStatus.NotFound, (await service.GetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, CancellationToken.None)).Status);
        Assert.Single(db.UserIdentities);

        await service.DeleteIdentityImageAsync(sa.Id, member.Id, IdentitySide.Back, CancellationToken.None);
        Assert.Empty(db.UserIdentities);
        // Removing what is not there is not an error.
        Assert.Equal(ResultStatus.Success, (await service.DeleteIdentityImageAsync(sa.Id, member.Id, IdentitySide.Back, CancellationToken.None)).Status);
    }

    [Fact]
    public async Task ThingsThatAreNotPicturesAreRefused()
    {
        using var testDb = TestDb.Create();
        var (service, db, sa, member) = await MemberAsync(testDb);

        var text = await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, "not an image"u8.ToArray(), CancellationToken.None);
        var pdf = await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, "%PDF-1.7 ..."u8.ToArray(), CancellationToken.None);
        var empty = await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, [], CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, text.Status);
        Assert.Equal(ResultStatus.ValidationFailed, pdf.Status);
        Assert.Equal(ResultStatus.ValidationFailed, empty.Status);
        Assert.Empty(db.UserIdentities);
    }

    [Fact]
    public async Task AnImageOver5MbIsRefused()
    {
        using var testDb = TestDb.Create();
        var (service, db, sa, member) = await MemberAsync(testDb);
        var big = new byte[UserService.MaxIdentityImageBytes + 1];
        Jpeg.CopyTo(big, 0);

        var result = await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, big, CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Empty(db.UserIdentities);
    }

    [Fact]
    public async Task TheTypeComesFromTheFileNotFromWhatTheClientSays()
    {
        Assert.Equal("image/jpeg", UserService.ImageContentType(Jpeg));
        Assert.Equal("image/png", UserService.ImageContentType(Png));
        Assert.Equal("image/webp", UserService.ImageContentType(Webp));
        Assert.Null(UserService.ImageContentType("GIF89a"u8.ToArray()));
        Assert.Null(UserService.ImageContentType([]));
        await Task.CompletedTask;
    }

    [Fact]
    public async Task IdentityImagesFollowWhoCanSeeAMember()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var retailerA = await TestUsers.AddAsync(db, "A", UserRole.Retailer, sa);
        var retailerB = await TestUsers.AddAsync(db, "B", UserRole.Retailer, retailerA);
        var retailerC = await TestUsers.AddAsync(db, "C", UserRole.Retailer, retailerB);
        var service = new UserService(db);
        await service.SetIdentityImageAsync(sa.Id, retailerC.Id, IdentitySide.Front, Jpeg, CancellationToken.None);

        // A retailer sees one level down: B sees C, A (two levels up from C) does not, and nobody sees upline.
        Assert.Equal(ResultStatus.Success, (await service.GetIdentityImageAsync(retailerB.Id, retailerC.Id, IdentitySide.Front, CancellationToken.None)).Status);
        Assert.Equal(ResultStatus.NotFound, (await service.GetIdentityImageAsync(retailerA.Id, retailerC.Id, IdentitySide.Front, CancellationToken.None)).Status);
        Assert.Equal(ResultStatus.Success, (await service.GetIdentityImageAsync(retailerC.Id, retailerC.Id, IdentitySide.Front, CancellationToken.None)).Status);
        Assert.Equal(ResultStatus.NotFound, (await service.GetIdentityImageAsync(retailerC.Id, retailerB.Id, IdentitySide.Front, CancellationToken.None)).Status);
    }

    [Fact]
    public async Task OnlyTheMemberOrWhoManagesThemMayChangeTheirIdentityImages()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var retailerA = await TestUsers.AddAsync(db, "A", UserRole.Retailer, sa);
        var retailerB = await TestUsers.AddAsync(db, "B", UserRole.Retailer, retailerA);
        var retailerC = await TestUsers.AddAsync(db, "C", UserRole.Retailer, retailerB);
        var service = new UserService(db);

        // A cannot see C at all, so cannot touch their images; B (their parent) and C themselves can.
        Assert.Equal(ResultStatus.NotFound, (await service.SetIdentityImageAsync(retailerA.Id, retailerC.Id, IdentitySide.Front, Jpeg, CancellationToken.None)).Status);
        Assert.Equal(ResultStatus.Success, (await service.SetIdentityImageAsync(retailerB.Id, retailerC.Id, IdentitySide.Front, Jpeg, CancellationToken.None)).Status);
        Assert.Equal(ResultStatus.Success, (await service.SetIdentityImageAsync(retailerC.Id, retailerC.Id, IdentitySide.Back, Png, CancellationToken.None)).Status);
        Assert.Equal(ResultStatus.NotFound, (await service.DeleteIdentityImageAsync(retailerA.Id, retailerC.Id, IdentitySide.Front, CancellationToken.None)).Status);
        Assert.Equal(ResultStatus.Success, (await service.DeleteIdentityImageAsync(retailerB.Id, retailerC.Id, IdentitySide.Front, CancellationToken.None)).Status);
    }

    [Fact]
    public async Task ADeletedMembersImagesGoWithThem()
    {
        using var testDb = TestDb.Create();
        var (service, db, sa, member) = await MemberAsync(testDb);
        await service.SetIdentityImageAsync(sa.Id, member.Id, IdentitySide.Front, Jpeg, CancellationToken.None);
        Assert.Single(db.UserIdentities);

        db.Users.Remove(member);
        await db.SaveChangesAsync();

        Assert.Empty(db.UserIdentities);
    }
}
