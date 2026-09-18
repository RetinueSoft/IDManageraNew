using IDManager.Api.Domain.Entities;
using IDManager.Api.Dtos;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Api.Persistence.Services;

public class UserService : IUserService
{
    private readonly ApplicationDbContext _db;

    public UserService(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<PagedResult<UserDto>> GetAllAsync(int requestedById, PagedRequest request)
    {
        var requester = await _db.Users.FindAsync(requestedById)
            ?? throw new ArgumentException("Requesting user not found.");

        // Admin/SuperAdmin see everyone below them; a Distributor only sees the Users
        // they created.
        var query = _db.Users.Where(u => u.Id != requester.Id);
        if (requester.Role == Domain.Enums.UserRole.Distributor)
            query = query.Where(u => u.CreatedById == requester.Id);

        if (!string.IsNullOrWhiteSpace(request.SearchBy))
            query = query.Where(u => u.Name.Contains(request.SearchBy) || u.Phone.Contains(request.SearchBy));

        var totalCount = await query.CountAsync();
        var items = await query
            .OrderByDescending(u => u.CreatedAt)
            .Skip((request.PageIndex - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(u => ToDto(u))
            .ToListAsync();

        return new PagedResult<UserDto>
        {
            Items = items,
            TotalCount = totalCount,
            PageIndex = request.PageIndex,
            PageSize = request.PageSize
        };
    }

    public async Task<UserDto> GetByIdAsync(int id)
    {
        var user = await _db.Users.FindAsync(id) ?? throw new ArgumentException("User not found.");
        return ToDto(user);
    }

    public async Task<UserDto> CreateAsync(int createdById, CreateUserRequest request)
    {
        if (await _db.Users.AnyAsync(u => u.Phone == request.Phone))
            throw new InvalidOperationException("A user with this phone number already exists.");

        var user = new User
        {
            Name = request.Name,
            Phone = request.Phone,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Role = request.Role,
            Status = true,
            CreatedById = createdById
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();
        return ToDto(user);
    }

    public async Task<UserDto> UpdateAsync(UpdateUserRequest request)
    {
        var user = await _db.Users.FindAsync(request.Id) ?? throw new ArgumentException("User not found.");
        user.Name = request.Name;
        user.Status = request.Status;
        if (!string.IsNullOrWhiteSpace(request.Password))
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
        user.ModifiedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();
        return ToDto(user);
    }

    public async Task DeactivateAsync(int id)
    {
        var user = await _db.Users.FindAsync(id) ?? throw new ArgumentException("User not found.");
        user.Status = false;
        user.ModifiedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
    }

    private static UserDto ToDto(User u) => new()
    {
        Id = u.Id,
        Name = u.Name,
        Phone = u.Phone,
        Role = u.Role,
        Status = u.Status,
        Points = u.Points,
        CreatedAt = u.CreatedAt
    };
}
