using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure;

namespace IDManager.Tests;

/// Builds members of the network in docs/member-hierarchy.md: each member's parent is
/// the member who created them (CreatedById).
public static class TestUsers
{
    public static async Task<UserEntity> AddAsync(
        IDManagerDbContext db, string name, UserRole role, UserEntity? parent = null, int points = 0, bool isActive = true)
    {
        var user = new UserEntity
        {
            Name = name,
            Phone = Guid.NewGuid().ToString("N")[..10],
            PasswordHash = "x",
            Role = role,
            Points = points,
            IsActive = isActive,
            CreatedById = parent?.Id,
        };
        db.Users.Add(user);
        await db.SaveChangesAsync();
        return user;
    }
}
