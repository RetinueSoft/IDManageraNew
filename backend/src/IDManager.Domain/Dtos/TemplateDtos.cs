namespace IDManager.Domain.Dtos;

public class TemplateSummaryDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public double CardWidthMm { get; set; }
    public double CardHeightMm { get; set; }
    public int PointCost { get; set; }
    public bool IsActive { get; set; }
    public string FrontImageBase64 { get; set; } = string.Empty;
    public string BackImageBase64 { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class TemplateDetailDto : TemplateSummaryDto
{
    public List<FieldGroupDto> Groups { get; set; } = new();
    public List<TemplateLayerDto> Layers { get; set; } = new();
    public List<CombinationDto> Combinations { get; set; } = new();
}

public class CombinationDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string FrontImageBase64 { get; set; } = string.Empty;
    public string BackImageBase64 { get; set; } = string.Empty;
}

/// Framework-independent command: the Api layer's endpoint is responsible for
/// pulling raw bytes out of the multipart request before calling into
/// Infrastructure - Domain never depends on ASP.NET's IFormFile.
public class CreateTemplateCommand
{
    public string Name { get; set; } = string.Empty;
    public double CardWidthMm { get; set; } = 85.6;
    public double CardHeightMm { get; set; } = 54.0;
    public int PointCost { get; set; } = 1;
    public string GroupsJson { get; set; } = "[]";
    public byte[] FrontImageBytes { get; set; } = Array.Empty<byte>();
    public byte[] BackImageBytes { get; set; } = Array.Empty<byte>();
}

public class UpdateTemplateCommand
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int PointCost { get; set; }
    public bool IsActive { get; set; }
    public string GroupsJson { get; set; } = "[]";
    public byte[]? FrontImageBytes { get; set; }
    public byte[]? BackImageBytes { get; set; }
}

public class SaveLayersRequest
{
    public int TemplateId { get; set; }
    public List<TemplateLayerDto> Layers { get; set; } = new();
}

public class AddCombinationCommand
{
    public int TemplateId { get; set; }
    public string Name { get; set; } = string.Empty;
    public byte[] FrontImageBytes { get; set; } = Array.Empty<byte>();
    public byte[] BackImageBytes { get; set; } = Array.Empty<byte>();
}
