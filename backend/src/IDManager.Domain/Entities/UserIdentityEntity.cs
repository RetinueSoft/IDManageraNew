namespace IDManager.Domain.Entities;

/// The front and back photos of a member's identity card. Kept apart from UserEntity (one row per
/// member, only when they have an image) so the images - which can be large - are never loaded
/// with the member itself, only when asked for.
public class UserIdentityEntity
{
    /// The member; also this row's key.
    public int UserId { get; set; }

    public byte[]? FrontImage { get; set; }
    public byte[]? BackImage { get; set; }
    public DateTime ModifiedAt { get; set; } = DateTime.UtcNow;
}
