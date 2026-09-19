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

        return members.Select(m =>
        {
            var dto = ToDto(m);
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
    };
}
