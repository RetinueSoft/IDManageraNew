namespace IDManager.Domain.Dtos;

public class GenerateCardCommand
{
    public int TemplateId { get; set; }
    public int CombinationId { get; set; }
    public byte[] PdfBytes { get; set; } = Array.Empty<byte>();
}

public class GenerateCardResponse
{
    public int IdCardId { get; set; }
    public List<TemplateLayerDto> Layers { get; set; } = new();
    public double CardWidthMm { get; set; }
    public double CardHeightMm { get; set; }
    public string FrontImageBase64 { get; set; } = string.Empty;
    public string BackImageBase64 { get; set; } = string.Empty;
}
