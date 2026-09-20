using System.Text.Json;
using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Points;
using IDManager.Infrastructure.Templates;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure.Cards;

/// Orchestrates the end-user card generation flow across the Templates and Points
/// services: extract → match → (pending) points deduction, then later render →
/// complete payment. This is the one place those two services' operations are
/// combined - neither service depends on the other directly.
public class CardService(
    IDManagerDbContext db,
    PdfExtractionService pdfExtractionService,
    PdfGenerationService pdfGenerationService,
    TemplateService templateService,
    PointsService pointsService)
{
    public List<ExtractedFieldDto> ParsePdf(byte[] pdfBytes) => pdfExtractionService.ExtractFields(pdfBytes);

    public async Task<OperationResult<GenerateCardResponse>> GenerateAsync(int userId, GenerateCardCommand command, CancellationToken ct)
    {
        var templateResult = await templateService.GetTemplateAsync(command.TemplateId, ct);
        if (templateResult.Status != ResultStatus.Success)
        {
            return OperationResult<GenerateCardResponse>.NotFound(templateResult.Error ?? "Template not found.");
        }
        var template = templateResult.Value!;

        var user = await db.Users.FindAsync([userId], ct);
        if (user is null) return OperationResult<GenerateCardResponse>.NotFound("User not found.");
        // The SuperAdmin's pool is unlimited (docs/member-hierarchy.md, section 5): they are
        // never blocked by a balance, and cannot allocate points to themselves anyway.
        if (user.Role != UserRole.SuperAdmin && user.Points < template.PointCost)
        {
            return OperationResult<GenerateCardResponse>.Invalid("You don't have enough points. Contact your admin.");
        }

        var extractedFields = pdfExtractionService.ExtractFields(command.PdfBytes);

        // Each QR image the user picked is read and a clean QR with the same content is
        // generated in its place, so a blurry, tilted or badly cropped upload still prints well
        // (and one that is not a QR at all is refused). The generated images are stored with the
        // extracted data (as image fields keyed by their slot), so the final download re-matches
        // them too.
        foreach (var qr in command.QrImages.Where(q => q.Bytes.Length > 0 && !string.IsNullOrWhiteSpace(q.Key)))
        {
            var regenerated = QrCodeRegenerator.Regenerate(qr.Bytes);
            if (regenerated is null)
            {
                return OperationResult<GenerateCardResponse>.Invalid(
                    $"Could not read a QR code from the image chosen for '{qr.Key}'. Upload a clear, properly cropped QR image.");
            }
            extractedFields.Add(new ExtractedFieldDto
            {
                Key = qr.Key,
                Type = LayerFieldType.Image,
                Value = Convert.ToBase64String(regenerated),
            });
        }

        var matchResult = await templateService.MatchToTemplateAsync(command.TemplateId, command.CombinationId, extractedFields, ct);
        if (matchResult.Status != ResultStatus.Success)
        {
            return OperationResult<GenerateCardResponse>.NotFound(matchResult.Error ?? "Combination not found.");
        }
        var (layers, frontImage, backImage) = matchResult.Value;

        var idCard = new IDCardEntity
        {
            UserId = userId,
            TemplateId = command.TemplateId,
            CombinationId = command.CombinationId > 0 ? command.CombinationId : null,
            ExtractedDataJson = JsonSerializer.Serialize(extractedFields),
            PointsDeducted = template.PointCost,
        };

        // The points history names the card the way its PDF will be named (from the template's
        // file name pattern); without a pattern, by the member's first text field.
        var forName = PdfFileNameBuilder.Build(template.FileNamePattern, FieldValues(extractedFields, layers))
            ?? extractedFields.FirstOrDefault(f => f.Type == LayerFieldType.Text)?.Value
            ?? "Unknown";
        var idCardId = await pointsService.CreateIdCardAsync(idCard, await CardLabelAsync(template.Name, command.CombinationId, ct), forName, ct);

        return OperationResult<GenerateCardResponse>.Success(new GenerateCardResponse
        {
            IdCardId = idCardId,
            Layers = layers,
            CardWidthMm = template.CardWidthMm,
            CardHeightMm = template.CardHeightMm,
            FrontImageBase64 = Convert.ToBase64String(frontImage),
            BackImageBase64 = Convert.ToBase64String(backImage),
        });
    }

    /// Renders the final print-ready PDF directly from the template's layer
    /// geometry (true vector positions, exact physical card size) and completes the
    /// pending points transaction - no client-side screenshotting involved.
    ///
    /// [adjustedLayers] are the layers as the user adjusted them on the preview; when given they
    /// are printed instead of the ones re-matched from the template (the images and the card
    /// size still come from the template). Null prints the template's layers with the stored
    /// member data.
    ///
    /// [combinationId] is the background the user last picked on the preview (0 = the template's
    /// own images); null keeps the one the card was generated with. It must belong to the
    /// card's template.
    public async Task<OperationResult<DownloadedCardDto>> DownloadAsync(
        int userId, int idCardId, List<TemplateLayerDto>? adjustedLayers, int? combinationId, CancellationToken ct)
    {
        var idCard = await db.IDCards.FirstOrDefaultAsync(c => c.Id == idCardId, ct);
        if (idCard is null) return OperationResult<DownloadedCardDto>.NotFound("Card not found.");
        if (idCard.UserId != userId) return OperationResult<DownloadedCardDto>.Forbidden("This card does not belong to you.");

        var templateResult = await templateService.GetTemplateAsync(idCard.TemplateId, ct);
        if (templateResult.Status != ResultStatus.Success)
        {
            return OperationResult<DownloadedCardDto>.NotFound(templateResult.Error ?? "Template not found.");
        }
        var template = templateResult.Value!;

        if (combinationId.HasValue)
        {
            if (combinationId.Value < 0) return OperationResult<DownloadedCardDto>.Invalid("Choose one of this template's backgrounds.");
            if (combinationId.Value > 0)
            {
                var combination = await db.TemplateCombinations.FindAsync([combinationId.Value], ct);
                if (combination is null || combination.TemplateId != idCard.TemplateId)
                {
                    return OperationResult<DownloadedCardDto>.Invalid("That background does not belong to this card's template.");
                }
            }
            idCard.CombinationId = combinationId.Value > 0 ? combinationId.Value : null;
        }

        var extractedFields = JsonSerializer.Deserialize<List<ExtractedFieldDto>>(idCard.ExtractedDataJson) ?? [];
        var matchResult = await templateService.MatchToTemplateAsync(idCard.TemplateId, idCard.CombinationId ?? 0, extractedFields, ct);
        if (matchResult.Status != ResultStatus.Success)
        {
            return OperationResult<DownloadedCardDto>.NotFound(matchResult.Error ?? "Combination not found.");
        }
        var (matchedLayers, frontImage, backImage) = matchResult.Value;
        var layers = adjustedLayers ?? matchedLayers;

        var pdfBytes = pdfGenerationService.GenerateCardPdf(frontImage, backImage, template.CardWidthMm, template.CardHeightMm, layers);

        var fileName = PdfFileNameBuilder.Build(template.FileNamePattern, FieldValues(extractedFields, layers))
            ?? $"card-{idCard.Id}";

        idCard.GeneratedPdf = pdfBytes;
        await db.SaveChangesAsync(ct);
        // The points history shows the card under the name the file is saved as (a value corrected
        // on the preview may have changed it since the card was generated).
        await pointsService.RenameCardTransactionsAsync(idCard.Id, await CardLabelAsync(template.Name, idCard.CombinationId ?? 0, ct), fileName, ct);
        await pointsService.CompletePaymentTransactionAsync(idCard.Id, ct);

        return OperationResult<DownloadedCardDto>.Success(new DownloadedCardDto { Pdf = pdfBytes, FileName = fileName });
    }

    /// What the points history calls a card: "<template name> <background name>", e.g. "Smart Card
    /// Blue" - the background is "Default" when the card is on the template's own images.
    private async Task<string> CardLabelAsync(string templateName, int combinationId, CancellationToken ct)
    {
        var background = "Default";
        if (combinationId > 0)
        {
            var combination = await db.TemplateCombinations.FindAsync([combinationId], ct);
            if (combination is not null && !string.IsNullOrWhiteSpace(combination.Name)) background = combination.Name.Trim();
        }
        return $"{templateName} {background}";
    }

    /// The values a file name pattern can use, by PDF field name: what was extracted from the
    /// member's PDF, overridden by what the card shows now (a value corrected on the preview wins,
    /// so the file is named after the card as it is printed).
    private static Dictionary<string, string> FieldValues(List<ExtractedFieldDto> extracted, List<TemplateLayerDto> layers)
    {
        var values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var field in extracted.Where(f => f.Type == LayerFieldType.Text && !string.IsNullOrWhiteSpace(f.Key) && !string.IsNullOrWhiteSpace(f.Value)))
        {
            values.TryAdd(field.Key!.Trim(), field.Value!);
        }

        foreach (var source in layers.SelectMany(l => l.Groups).SelectMany(g => g.Sources))
        {
            var readKey = !string.IsNullOrWhiteSpace(source.SourceKey) ? source.SourceKey.Trim()
                : !string.IsNullOrWhiteSpace(source.Key) ? source.Key.Trim()
                : null;
            if (readKey is null || source.Type != LayerFieldType.Text || string.IsNullOrWhiteSpace(source.Value)) continue;
            values[readKey] = source.Value;
        }
        return values;
    }
}
