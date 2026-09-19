namespace IDManager.Domain.Entities;

/// A card's physical geometry is fixed in millimeters so that on-screen zoom is a
/// pure view transform, and print/PDF export renders at true size regardless of the
/// source image's pixel resolution.
public class CardTemplateEntity
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    public double CardWidthMm { get; set; } = 85.6;
    public double CardHeightMm { get; set; } = 54.0;

    public byte[] FrontImage { get; set; } = Array.Empty<byte>();
    public byte[] BackImage { get; set; } = Array.Empty<byte>();

    /// Field groups defined from a parsed sample PDF - JSON, see FieldGroupDto.
    public string GroupsJson { get; set; } = "[]";

    /// Layer positions (front + back) - JSON, see TemplateLayerDto. Geometry is
    /// always in mm relative to CardWidthMm/CardHeightMm.
    public string? LayersJson { get; set; }

    public string? ParsedPdfJson { get; set; }

    public int PointCost { get; set; } = 1;
    public bool IsActive { get; set; } = true;

    public int CreatedById { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime ModifiedAt { get; set; } = DateTime.UtcNow;

    public List<TemplateCombinationEntity> Combinations { get; set; } = new();
}

/// One template can offer several front/back image variants (e.g. different
/// watermarks) that an end user picks from before generating their card.
public class TemplateCombinationEntity
{
    public int Id { get; set; }
    public int TemplateId { get; set; }
    public CardTemplateEntity? Template { get; set; }

    public string Name { get; set; } = string.Empty;
    public byte[] FrontImage { get; set; } = Array.Empty<byte>();
    public byte[] BackImage { get; set; } = Array.Empty<byte>();
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
