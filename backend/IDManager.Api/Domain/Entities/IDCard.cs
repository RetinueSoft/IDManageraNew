namespace IDManager.Api.Domain.Entities;

public class IDCard
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int TemplateId { get; set; }
    public int? CombinationId { get; set; }

    // Values extracted from the member's uploaded PDF, matched against the template's
    // group definitions (JSON - see ExtractedFieldDto).
    public string ExtractedDataJson { get; set; } = "{}";

    public byte[]? GeneratedPdf { get; set; }
    public int PointsDeducted { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
