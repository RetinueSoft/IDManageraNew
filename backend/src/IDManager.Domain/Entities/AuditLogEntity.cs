namespace IDManager.Domain.Entities;

public class AuditLogEntity
{
    public int Id { get; set; }
    public int? UserId { get; set; }
    public string Action { get; set; } = string.Empty;
    public string EntityName { get; set; } = string.Empty;
    public string? EntityId { get; set; }
    public string? DetailsJson { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
