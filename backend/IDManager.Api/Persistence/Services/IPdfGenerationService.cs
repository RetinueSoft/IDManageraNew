using IDManager.Api.Dtos;

namespace IDManager.Api.Persistence.Services;

public interface IPdfGenerationService
{
    // Renders the card as true vector content (positioned text + images), sized to the
    // template's exact physical dimensions - not a rasterized screenshot - so print
    // output is crisp regardless of the screen resolution the layers were designed at.
    byte[] GenerateCardPdf(
        byte[] frontImage,
        byte[] backImage,
        double cardWidthMm,
        double cardHeightMm,
        List<TemplateLayerDto> layers);
}
