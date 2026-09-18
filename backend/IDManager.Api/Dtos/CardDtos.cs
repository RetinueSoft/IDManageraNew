namespace IDManager.Api.Dtos;

public class ParsePdfRequest
{
    public IFormFile File { get; set; } = default!;
}

public class GenerateCardRequest
{
    public int TemplateId { get; set; }
    public int CombinationId { get; set; }
    public IFormFile File { get; set; } = default!;
}

public class GenerateCardResponse
{
    public int IdCardId { get; set; }
    public List<FieldGroupDto> MatchedGroups { get; set; } = new();
    public List<TemplateLayerDto> Layers { get; set; } = new();
    public double CardWidthMm { get; set; }
    public double CardHeightMm { get; set; }
    public string FrontImageBase64 { get; set; } = string.Empty;
    public string BackImageBase64 { get; set; } = string.Empty;
}

public class DownloadCardPdfRequest
{
    public int IdCardId { get; set; }
}
