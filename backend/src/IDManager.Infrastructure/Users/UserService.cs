using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Members;
using IDManager.Infrastructure.Security;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure.Users;

/// Member management. Which members a caller may create / see / change is decided by
/// MemberHierarchyService (docs/member-hierarchy.md) - this class only applies it.
public class UserService(IDManagerDbContext db)
{
    private readonly MemberHierarchyService _hierarchy = new(db);

    /// The most an identity card image may weigh.
    public const int MaxIdentityImageBytes = 5 * 1024 * 1024;

    // Longest values for the optional profile fields.
    private const int MaxShopName = 150, MaxShopAddress = 500, MaxCity = 100, MaxPincode = 20, MaxIdType = 50, MaxIdNumber = 50;

    private static string? Clean(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    /// Too-long profile values, by field.
    private static Dictionary<string, string> ProfileErrors(UserProfileFields fields)
    {
        var errors = new Dictionary<string, string>();
        void Check(string key, string? value, int max, string label)
        {
            if (Clean(value)?.Length > max) errors[key] = $"{label} can be at most {max} characters.";
        }
        Check("shopName", fields.ShopName, MaxShopName, "Shop name");
        Check("shopAddress", fields.ShopAddress, MaxShopAddress, "Shop address");
        Check("city", fields.City, MaxCity, "City");
        Check("pincode", fields.Pincode, MaxPincode, "Pincode");
        Check("idType", fields.IdType, MaxIdType, "ID type");
        Check("idNumber", fields.IdNumber, MaxIdNumber, "ID number");
        return errors;
    }

    /// Stores the profile fields. A null field is left as it was (an older client that does not send
    /// it must not wipe it); a blank one clears it.
    private static void ApplyProfile(UserEntity user, UserProfileFields fields)
    {
        if (fields.ShopName is not null) user.ShopName = Clean(fields.ShopName);
        if (fields.ShopAddress is not null) user.ShopAddress = Clean(fields.ShopAddress);
        if (fields.City is not null) user.City = Clean(fields.City);
        if (fields.Pincode is not null) user.Pincode = Clean(fields.Pincode);
        if (fields.IdType is not null) user.IdType = Clean(fields.IdType);
        if (fields.IdNumber is not null) user.IdNumber = Clean(fields.IdNumber);
    }

    public async Task<PagedResult<UserDto>> GetAllAsync(int requestedById, PagedRequest request, CancellationToken ct)
    {
        var requester = await db.Users.FindAsync([requestedById], ct);
        if (requester is null)
        {
            return new PagedResult<UserDto> { PageIndex = request.PageIndex, PageSize = request.PageSize };
        }

        var query = await _hierarchy.GetVisibleMembersAsync(requester, ct);
        if (!string.IsNullOrWhiteSpace(request.SearchBy))
        {
            query = query.Where(u => u.Name.Contains(request.SearchBy) || u.Phone.Contains(request.SearchBy));
        }

        var totalCount = await query.CountAsync(ct);
        var members = await query
            .OrderByDescending(u => u.CreatedAt)
            .Skip((request.PageIndex - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(ct);

        return new PagedResult<UserDto>
        {
            Items = await ToDtosAsync(requester, members, ct),
            TotalCount = totalCount,
            PageIndex = request.PageIndex,
            PageSize = request.PageSize,
        };
    }

    /// A member outside the caller's visible set is reported as not found, so their
    /// existence isn't leaked.
    public async Task<OperationResult<UserDto>> GetByIdAsync(int requestedById, int id, CancellationToken ct)
    {
        var requester = await db.Users.FindAsync([requestedById], ct);
        var user = await db.Users.FindAsync([id], ct);
        if (requester is null || user is null || !await _hierarchy.CanViewAsync(requester, id, ct))
        {
            return OperationResult<UserDto>.NotFound("User not found.");
        }

        return OperationResult<UserDto>.Success((await ToDtosAsync(requester, [user], ct))[0]);
    }

    public async Task<OperationResult<UserDto>> CreateAsync(int createdById, CreateUserRequest request, CancellationToken ct)
    {
        var errors = new Dictionary<string, string>();
        if (string.IsNullOrWhiteSpace(request.Name)) errors["name"] = "Name is required.";
        if (string.IsNullOrWhiteSpace(request.Phone)) errors["phone"] = "Phone is required.";
        else if (await db.Users.AnyAsync(u => u.Phone == request.Phone, ct))
        {
            errors["phone"] = "A user with this phone number already exists.";
        }
        if (string.IsNullOrWhiteSpace(request.Password)) errors["password"] = "Password is required.";
        foreach (var (key, message) in ProfileErrors(request)) errors[key] = message;
        if (errors.Count > 0) return OperationResult<UserDto>.Invalid(errors);

        var creator = await db.Users.FindAsync([createdById], ct);
        if (creator is null) return OperationResult<UserDto>.NotFound("Creating user not found.");
        if (!MemberHierarchyService.CanCreate(creator.Role, request.Role))
        {
            return OperationResult<UserDto>.Forbidden($"A {creator.Role} cannot add a {request.Role}.");
        }

        var user = new UserEntity
        {
            Name = request.Name,
            Phone = request.Phone,
            PasswordHash = PasswordHasher.Hash(request.Password),
            Role = request.Role,
            IsActive = true,
            CreatedById = createdById,
        };
        ApplyProfile(user, request);

        db.Users.Add(user);
        await db.SaveChangesAsync(ct);
        return OperationResult<UserDto>.Success((await ToDtosAsync(creator, [user], ct))[0]);
    }

    /// A member can edit their own name/password, and rename the members they manage.
    /// Only the member themselves or a SuperAdmin can change a password, and only a
    /// SuperAdmin can activate or deactivate a member (docs/member-hierarchy.md, section
    /// 4). Nobody deactivates themselves.
    public async Task<OperationResult<UserDto>> UpdateAsync(int requestedById, UpdateUserRequest request, CancellationToken ct)
    {
        var requester = await db.Users.FindAsync([requestedById], ct);
        var user = await db.Users.FindAsync([request.Id], ct);
        var isSelf = requester is not null && requester.Id == request.Id;
        if (requester is null || user is null || (!isSelf && !await _hierarchy.CanManageAsync(requester, request.Id, ct)))
        {
            return OperationResult<UserDto>.NotFound("User not found.");
        }

        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return OperationResult<UserDto>.Invalid(new Dictionary<string, string> { ["name"] = "Name is required." });
        }
        var profileErrors = ProfileErrors(request);
        if (profileErrors.Count > 0) return OperationResult<UserDto>.Invalid(profileErrors);
        if (isSelf && !request.IsActive)
        {
            return OperationResult<UserDto>.Invalid(new Dictionary<string, string> { ["isActive"] = "You cannot deactivate your own account." });
        }
        if (!string.IsNullOrWhiteSpace(request.Password) && !isSelf && requester.Role != UserRole.SuperAdmin)
        {
            return OperationResult<UserDto>.Forbidden("Only the member themselves or a Super Admin can change a password.");
        }
        if (request.IsActive != user.IsActive && requester.Role != UserRole.SuperAdmin)
        {
            return OperationResult<UserDto>.Forbidden("Only a Super Admin can activate or deactivate a member.");
        }

        user.Name = request.Name;
        user.IsActive = request.IsActive;
        ApplyProfile(user, request);
        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            user.PasswordHash = PasswordHasher.Hash(request.Password);
        }
        user.ModifiedAt = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);
        return OperationResult<UserDto>.Success((await ToDtosAsync(requester, [user], ct))[0]);
    }

    public async Task<OperationResult> DeactivateAsync(int requestedById, int id, CancellationToken ct)
    {
        var requester = await db.Users.FindAsync([requestedById], ct);
        var user = await db.Users.FindAsync([id], ct);
        if (requester is null || user is null) return OperationResult.NotFound("User not found.");
        if (requester.Role != UserRole.SuperAdmin)
        {
            return OperationResult.Forbidden("Only a Super Admin can activate or deactivate a member.");
        }
        if (requester.Id == id) return OperationResult.Invalid("You cannot deactivate your own account.");
        if (!await _hierarchy.CanManageAsync(requester, id, ct)) return OperationResult.NotFound("User not found.");

        user.IsActive = false;
        user.ModifiedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return OperationResult.Success();
    }

    /// Maps members to DTOs, attaching each one's parent - but only when the viewer is
    /// allowed to see that parent (a viewer never sees their own upline).
    private async Task<List<UserDto>> ToDtosAsync(UserEntity viewer, List<UserEntity> members, CancellationToken ct)
    {
        var parentIds = members.Where(m => m.CreatedById != null).Select(m => (int)m.CreatedById!).Distinct().ToList();
        var parents = new Dictionary<int, (string Name, UserRole Role)>();
        if (parentIds.Count > 0)
        {
            var visible = await _hierarchy.GetVisibleMembersAsync(viewer, ct);
            var found = await visible
                .Where(p => parentIds.Contains(p.Id))
                .Select(p => new { p.Id, p.Name, p.Role })
                .ToListAsync(ct);
            parents = found.ToDictionary(p => p.Id, p => (p.Name, p.Role));
        }

        // Which members have identity card images - asked without loading the images themselves.
        var memberIds = members.Select(m => m.Id).ToList();
        var identities = (await db.UserIdentities
            .Where(i => memberIds.Contains(i.UserId))
            .Select(i => new { i.UserId, Front = i.FrontImage != null, Back = i.BackImage != null })
            .ToListAsync(ct)).ToDictionary(i => i.UserId);

        return members.Select(m =>
        {
            var dto = ToDto(m);
            if (identities.TryGetValue(m.Id, out var identity))
            {
                dto.HasIdFront = identity.Front;
                dto.HasIdBack = identity.Back;
            }
            if (m.CreatedById is int parentId && parents.TryGetValue(parentId, out var parent))
            {
                dto.ParentId = parentId;
                dto.ParentName = parent.Name;
                dto.ParentRole = parent.Role;
            }
            return dto;
        }).ToList();
    }

    private static UserDto ToDto(UserEntity u) => new()
    {
        Id = u.Id,
        Name = u.Name,
        Phone = u.Phone,
        Role = u.Role,
        IsActive = u.IsActive,
        Points = u.Points,
        CreatedAt = u.CreatedAt,
        ShopName = u.ShopName,
        ShopAddress = u.ShopAddress,
        City = u.City,
        Pincode = u.Pincode,
        IdType = u.IdType,
        IdNumber = u.IdNumber,
    };

    // ---------------------------------------------------------------- identity card images

    /// Who may add, replace or remove a member's identity images: the member themselves, or a
    /// member who manages them - the same rule as editing their details (UpdateAsync).
    private async Task<UserEntity?> FindEditableAsync(int requestedById, int userId, CancellationToken ct)
    {
        var requester = await db.Users.FindAsync([requestedById], ct);
        var user = await db.Users.FindAsync([userId], ct);
        if (requester is null || user is null) return null;
        var isSelf = requester.Id == userId;
        return isSelf || await _hierarchy.CanManageAsync(requester, userId, ct) ? user : null;
    }

    public async Task<OperationResult> SetIdentityImageAsync(int requestedById, int userId, IdentitySide side, byte[] bytes, CancellationToken ct)
    {
        if (await FindEditableAsync(requestedById, userId, ct) is null) return OperationResult.NotFound("User not found.");
        if (bytes.Length == 0) return OperationResult.Invalid("Choose an image.");
        if (bytes.Length > MaxIdentityImageBytes) return OperationResult.Invalid("The image is larger than 5 MB.");
        if (ImageContentType(bytes) is null) return OperationResult.Invalid("That file is not a picture (use JPG, PNG or WebP).");

        var identity = await db.UserIdentities.FindAsync([userId], ct);
        if (identity is null)
        {
            identity = new UserIdentityEntity { UserId = userId };
            db.UserIdentities.Add(identity);
        }
        if (side == IdentitySide.Front) identity.FrontImage = bytes; else identity.BackImage = bytes;
        identity.ModifiedAt = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);
        return OperationResult.Success();
    }

    public async Task<OperationResult> DeleteIdentityImageAsync(int requestedById, int userId, IdentitySide side, CancellationToken ct)
    {
        if (await FindEditableAsync(requestedById, userId, ct) is null) return OperationResult.NotFound("User not found.");

        var identity = await db.UserIdentities.FindAsync([userId], ct);
        if (identity is null) return OperationResult.Success();

        if (side == IdentitySide.Front) identity.FrontImage = null; else identity.BackImage = null;
        if (identity.FrontImage is null && identity.BackImage is null) db.UserIdentities.Remove(identity);
        else identity.ModifiedAt = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);
        return OperationResult.Success();
    }

    /// An identity image, for whoever may see the member (docs/member-hierarchy.md, section 3). A
    /// member outside the caller's view, or one without that image, is reported as not found.
    public async Task<OperationResult<IdentityImageDto>> GetIdentityImageAsync(int requestedById, int userId, IdentitySide side, CancellationToken ct)
    {
        var requester = await db.Users.FindAsync([requestedById], ct);
        if (requester is null || !await _hierarchy.CanViewAsync(requester, userId, ct))
        {
            return OperationResult<IdentityImageDto>.NotFound("User not found.");
        }

        var identity = await db.UserIdentities.FindAsync([userId], ct);
        var bytes = side == IdentitySide.Front ? identity?.FrontImage : identity?.BackImage;
        if (bytes is null) return OperationResult<IdentityImageDto>.NotFound("No image.");

        return OperationResult<IdentityImageDto>.Success(new IdentityImageDto
        {
            Bytes = bytes,
            ContentType = ImageContentType(bytes) ?? "application/octet-stream",
        });
    }

    /// The image type from the file's own first bytes (never the client's word for it), or null when
    /// it is not a picture we accept.
    internal static string? ImageContentType(byte[] b)
    {
        if (b.Length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return "image/jpeg";
        if (b.Length >= 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return "image/png";
        if (b.Length >= 12 && b[0] == (byte)'R' && b[1] == (byte)'I' && b[2] == (byte)'F' && b[3] == (byte)'F'
            && b[8] == (byte)'W' && b[9] == (byte)'E' && b[10] == (byte)'B' && b[11] == (byte)'P') return "image/webp";
        return null;
    }
}
