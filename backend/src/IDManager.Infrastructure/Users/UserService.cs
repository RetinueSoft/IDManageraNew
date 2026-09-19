using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Security;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure.Users;

public class UserService(IDManagerDbContext db)
{
    public async Task<PagedResult<UserDto>> GetAllAsync(int requestedById, PagedRequest request, CancellationToken ct)
    {
        var requester = await db.Users.FindAsync([requestedById], ct);

        // Admin/SuperAdmin see everyone below them; a Distributor only sees the
        // Users they created.
        var query = db.Users.AsQueryable();
        if (requester is not null) query = query.Where(u => u.Id != requester.Id);
        if (requester?.Role == UserRole.Distributor)
        {
            query = query.Where(u => u.CreatedById == requester.Id);
        }
        if (!string.IsNullOrWhiteSpace(request.SearchBy))
        {
            query = query.Where(u => u.Name.Contains(request.SearchBy) || u.Phone.Contains(request.SearchBy));
        }

        var totalCount = await query.CountAsync(ct);
        var items = await query
            .OrderByDescending(u => u.CreatedAt)
            .Skip((request.PageIndex - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(u => ToDto(u))
            .ToListAsync(ct);

        return new PagedResult<UserDto>
        {
            Items = items,
            TotalCount = totalCount,
            PageIndex = request.PageIndex,
            PageSize = request.PageSize,
        };
    }

    public async Task<OperationResult<UserDto>> GetByIdAsync(int id, CancellationToken ct)
    {
        var user = await db.Users.FindAsync([id], ct);
        return user is null
            ? OperationResult<UserDto>.NotFound("User not found.")
            : OperationResult<UserDto>.Success(ToDto(user));
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
        return OperationResult<UserDto>.Success(ToDto(user));
    }

    public async Task<OperationResult<UserDto>> UpdateAsync(UpdateUserRequest request, CancellationToken ct)
    {
        var user = await db.Users.FindAsync([request.Id], ct);
        if (user is null) return OperationResult<UserDto>.NotFound("User not found.");

        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return OperationResult<UserDto>.Invalid(new Dictionary<string, string> { ["name"] = "Name is required." });
        }

        user.Name = request.Name;
        user.IsActive = request.IsActive;
        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            user.PasswordHash = PasswordHasher.Hash(request.Password);
        }
        user.ModifiedAt = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);
        return OperationResult<UserDto>.Success(ToDto(user));
    }

    public async Task<OperationResult> DeactivateAsync(int id, CancellationToken ct)
    {
        var user = await db.Users.FindAsync([id], ct);
        if (user is null) return OperationResult.NotFound("User not found.");

        user.IsActive = false;
        user.ModifiedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return OperationResult.Success();
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
