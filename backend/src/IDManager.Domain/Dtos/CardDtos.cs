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

public class DownloadCardRequest
{
    /// The card's layers as the user adjusted them in the preview (positions, sizes, values).
    /// When present these are printed instead of the layers re-matched from the template.
    public List<TemplateLayerDto>? Layers { get; set; }

    /// The background chosen on the preview (0 = the template's own). The user can switch it after
    /// generating, so the card is printed on what they last picked. Null keeps the one the card
    /// was generated with.
    public int? CombinationId { get; set; }
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
