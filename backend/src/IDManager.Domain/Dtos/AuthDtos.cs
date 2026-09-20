using IDManager.Domain.Enums;

namespace IDManager.Domain.Dtos;

public class LoginRequest
{
    public string Phone { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class LoginResponse
{
    public string AccessToken { get; set; } = string.Empty;
    public UserDto User { get; set; } = new();
}

public class UserDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public UserRole Role { get; set; }
    public bool IsActive { get; set; }
    public int Points { get; set; }
    public DateTime CreatedAt { get; set; }

    /// The member who created this one, when the viewer is allowed to see them (see
    /// docs/member-hierarchy.md - a viewer never sees their own upline).
    public int? ParentId { get; set; }
    public string? ParentName { get; set; }
    public UserRole? ParentRole { get; set; }

    // Optional profile details.
    public string? ShopName { get; set; }
    public string? ShopAddress { get; set; }
    public string? City { get; set; }
    public string? Pincode { get; set; }
    public string? IdType { get; set; }
    public string? IdNumber { get; set; }

    /// Whether the identity card images exist. The images themselves are fetched separately
    /// (they are large and sensitive), never sent in a list.
    public bool HasIdFront { get; set; }
    public bool HasIdBack { get; set; }
}

/// The optional details of a member: a shop and an identity proof. Every field is optional; a
/// blank one is stored as nothing.
/// One of a member's identity card images, as bytes with its type.
public class IdentityImageDto
{
    public byte[] Bytes { get; set; } = Array.Empty<byte>();
    public string ContentType { get; set; } = "application/octet-stream";
}

public enum IdentitySide
{
    Front,
    Back,
}

public class UserProfileFields
{
    public string? ShopName { get; set; }
    public string? ShopAddress { get; set; }
    public string? City { get; set; }
    public string? Pincode { get; set; }
    public string? IdType { get; set; }
    public string? IdNumber { get; set; }
}

public class CreateUserRequest : UserProfileFields
{
    public string Name { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public UserRole Role { get; set; }
}

/// A null profile field leaves the stored value unchanged; a blank one clears it.
public class UpdateUserRequest : UserProfileFields
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public string? Password { get; set; }
}
