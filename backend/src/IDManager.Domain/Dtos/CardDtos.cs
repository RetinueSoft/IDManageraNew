namespace IDManager.Domain.Dtos;

public class GenerateCardCommand
{
    public int TemplateId { get; set; }
    public int CombinationId { get; set; }
    public byte[] PdfBytes { get; set; } = Array.Empty<byte>();

    /// Images the user picked for the template's QR slots.
    public List<QrImageDto> QrImages { get; set; } = new();
}

public class QrImageDto
{
    /// The QR layer's source key (e.g. "QR 1").
    public string Key { get; set; } = string.Empty;
    public byte[] Bytes { get; set; } = Array.Empty<byte>();
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
