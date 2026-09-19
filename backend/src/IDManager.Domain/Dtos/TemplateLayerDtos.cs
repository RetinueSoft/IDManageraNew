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
    public bool IsList { get; set; }
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
    public string? Separator { get; set; }
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
