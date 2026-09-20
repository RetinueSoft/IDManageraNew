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

        var nameField = extractedFields.FirstOrDefault(f => f.Type == LayerFieldType.Text);
        var idCardId = await pointsService.CreateIdCardAsync(idCard, nameField?.Value ?? "Unknown", ct);

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
    public async Task<OperationResult<byte[]>> DownloadAsync(
        int userId, int idCardId, List<TemplateLayerDto>? adjustedLayers, CancellationToken ct)
    {
        var idCard = await db.IDCards.FirstOrDefaultAsync(c => c.Id == idCardId, ct);
        if (idCard is null) return OperationResult<byte[]>.NotFound("Card not found.");
        if (idCard.UserId != userId) return OperationResult<byte[]>.Forbidden("This card does not belong to you.");

        var templateResult = await templateService.GetTemplateAsync(idCard.TemplateId, ct);
        if (templateResult.Status != ResultStatus.Success)
        {
            return OperationResult<byte[]>.NotFound(templateResult.Error ?? "Template not found.");
        }
        var template = templateResult.Value!;

        var extractedFields = JsonSerializer.Deserialize<List<ExtractedFieldDto>>(idCard.ExtractedDataJson) ?? [];
        var matchResult = await templateService.MatchToTemplateAsync(idCard.TemplateId, idCard.CombinationId ?? 0, extractedFields, ct);
        if (matchResult.Status != ResultStatus.Success)
        {
            return OperationResult<byte[]>.NotFound(matchResult.Error ?? "Combination not found.");
        }
        var (matchedLayers, frontImage, backImage) = matchResult.Value;
        var layers = adjustedLayers ?? matchedLayers;

        var pdfBytes = pdfGenerationService.GenerateCardPdf(frontImage, backImage, template.CardWidthMm, template.CardHeightMm, layers);

        idCard.GeneratedPdf = pdfBytes;
        await db.SaveChangesAsync(ct);
        await pointsService.CompletePaymentTransactionAsync(idCard.Id, ct);

        return OperationResult<byte[]>.Success(pdfBytes);
    }
}
