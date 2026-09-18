namespace IDManager.Api.Domain.Entities;

// A card's physical geometry is fixed in millimeters so that on-screen zoom is a pure
// view transform, and print/PDF export renders at true size regardless of the source
// image's pixel resolution.
public class CardTemplate
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    public double CardWidthMm { get; set; } = 85.6;   // CR80 card size by default
    public double CardHeightMm { get; set; } = 54.0;

    public byte[] FrontImage { get; set; } = Array.Empty<byte>();
    public byte[] BackImage { get; set; } = Array.Empty<byte>();

    // Sample PDF field extraction result used to define the template's group boxes
    // (see FieldGroupDto) - JSON, since its shape mirrors whatever fields a given
    // organisation's source PDF happens to contain.
    public string GroupsJson { get; set; } = "[]";

    // Layer positions (front + back), stored as JSON - see TemplateLayerDto. Layer
    // geometry is always in mm relative to CardWidthMm/CardHeightMm.
    public string? LayersJson { get; set; }

    // Raw parsed sample PDF, kept so the designer can be reopened against the same data.
    public string? ParsedPdfJson { get; set; }

    public int PointCost { get; set; } = 1;
    public bool Status { get; set; } = true;

    public int CreatedById { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime ModifiedAt { get; set; } = DateTime.UtcNow;

    public List<TemplateCombination> Combinations { get; set; } = new();
}

// One template can offer several front/back image variants (e.g. different watermarks)
// that an end user picks from before generating their card.
public class TemplateCombination
{
    public int Id { get; set; }
    public int TemplateId { get; set; }
    public CardTemplate? Template { get; set; }

    public string Name { get; set; } = string.Empty;
    public byte[] FrontImage { get; set; } = Array.Empty<byte>();
    public byte[] BackImage { get; set; } = Array.Empty<byte>();
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
