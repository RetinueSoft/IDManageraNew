namespace IDManager.Api.Dtos;

public class TemplateSummaryDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public double CardWidthMm { get; set; }
    public double CardHeightMm { get; set; }
    public int PointCost { get; set; }
    public bool Status { get; set; }
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

public class CreateTemplateRequest
{
    public string Name { get; set; } = string.Empty;
    public double CardWidthMm { get; set; } = 85.6;
    public double CardHeightMm { get; set; } = 54.0;
    public int PointCost { get; set; } = 1;
    public IFormFile? FrontFile { get; set; }
    public IFormFile? BackFile { get; set; }
    public string GroupsJson { get; set; } = "[]";
}

public class UpdateTemplateRequest
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int PointCost { get; set; }
    public bool Status { get; set; }
    public IFormFile? FrontFile { get; set; }
    public IFormFile? BackFile { get; set; }
    public string GroupsJson { get; set; } = "[]";
}

public class SaveLayersRequest
{
    public int TemplateId { get; set; }
    public List<TemplateLayerDto> Layers { get; set; } = new();
}

public class AddCombinationRequest
{
    public int TemplateId { get; set; }
    public string Name { get; set; } = string.Empty;
    public IFormFile FrontFile { get; set; } = default!;
    public IFormFile BackFile { get; set; } = default!;
}
