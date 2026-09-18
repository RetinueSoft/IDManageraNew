using IDManager.Api.Domain.Enums;

namespace IDManager.Api.Domain.Entities;

public class User
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public UserRole Role { get; set; } = UserRole.User;
    public bool Status { get; set; } = true;
    public int Points { get; set; } = 0;

    // The user who created this account (Admin creates Distributors, Distributor creates Users)
    public int? CreatedById { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime ModifiedAt { get; set; } = DateTime.UtcNow;
}
