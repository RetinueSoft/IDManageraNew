namespace IDManager.Domain.Entities;

public class IDCardEntity
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int TemplateId { get; set; }
    public int? CombinationId { get; set; }

    /// Values extracted from the member's uploaded PDF, matched against the
    /// template's layer sources by key (JSON - see ExtractedFieldDto).
    public string ExtractedDataJson { get; set; } = "{}";

    /// 0 = the Tamil text in ExtractedDataJson is still in glyph order (saved before the
    /// Tamil fix); 1 = logical Unicode order. See TextOrderMigrationService. New rows are 1.
    public int TextOrderVersion { get; set; } = 1;

    public byte[]? GeneratedPdf { get; set; }
    public int PointsDeducted { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
