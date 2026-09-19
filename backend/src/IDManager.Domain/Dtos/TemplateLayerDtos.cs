using IDManager.Domain.Enums;

namespace IDManager.Domain.Dtos;

/// The physical-unit layer model shared conceptually with the Flutter client. All
/// geometry is in millimeters relative to the template's CardWidthMm/CardHeightMm,
/// so on-screen zoom is a pure view transform and PDF export renders at true size.
public class TemplateLayerDto
{
    public CardSide Side { get; set; }
    public List<LayerGroupDto> Groups { get; set; } = new();
}

public class LayerGroupDto
{
    public string Name { get; set; } = string.Empty;
    public LayerFieldType FieldType { get; set; } = LayerFieldType.Text;

    public double XMm { get; set; }
    public double YMm { get; set; }
    public double? WidthMm { get; set; }
    public double? HeightMm { get; set; }

    public double FontSizePt { get; set; } = 10;
    public double LineHeightMm { get; set; } = 5;
    public double? KeyWidthMm { get; set; }
    public double? ValueWidthMm { get; set; }

    public bool Bold { get; set; }
    /// A combined group: all Sources are rendered as one text - each "key: value" (just
    /// the value when the key is empty) - joined by each source's own separator (comma
    /// by default). With KeyWidthMm every field is its own row and the keys share one aligned column.
    public bool IsList { get; set; }

    /// An image layer left empty in the template that the card generator fills with
    /// an image the user picks (a QR code). Its single source's Key names the slot.
    public bool IsQr { get; set; }

    /// In a combined group: extra space (mm) added between all of its lines, common to
    /// the whole group. 0 keeps the normal line spacing.
    public double LineGapMm { get; set; }

    /// A combined group prints each field on its own line with a bullet point.
    public bool BulletList { get; set; }
    public bool EmptyLineEveryAfter { get; set; }
    public bool NewLineAfterFirst { get; set; }
    public bool NewLineBeforeLast { get; set; }
    public bool FormatAsDate { get; set; }
    public bool UseDashSeparator { get; set; }

    public List<LayerSourceItemDto> Sources { get; set; } = new();
}

public class LayerSourceItemDto
{
    public string? Key { get; set; }
    public string? Value { get; set; }
    public LayerFieldType Type { get; set; } = LayerFieldType.Text;

    /// In a combined group: how this source joins the NEXT one ("comma", "dash",
    /// "space" or "newline"). Null means comma.
    public string? Separator { get; set; }

    /// In a combined group: this entry is not a field but one empty line.
    public bool EmptyLine { get; set; }
}

/// A named group of fields defined from a parsed sample PDF, used to populate the
/// designer's "available fields" palette when positioning layers.
public class FieldGroupDto
{
    public string Name { get; set; } = string.Empty;
    public int Index { get; set; }
    public List<ExtractedFieldDto> Items { get; set; } = new();
}

public class ExtractedFieldDto
{
    public string? Key { get; set; }
    public string? Value { get; set; }
    public LayerFieldType Type { get; set; } = LayerFieldType.Text;
}
