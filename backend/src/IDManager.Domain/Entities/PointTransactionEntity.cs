using IDManager.Domain.Enums;

namespace IDManager.Domain.Entities;

public class PointTransactionEntity
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int ByUserId { get; set; }
    public int Points { get; set; }
    public PointTransType Type { get; set; }
    public PointStatus Status { get; set; } = PointStatus.Completed;
    public string Reason { get; set; } = string.Empty;
    public int? ForIdCardId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
