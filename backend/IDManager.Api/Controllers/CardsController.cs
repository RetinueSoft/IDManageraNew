using System.Text.Json;
using IDManager.Api.Domain.Entities;
using IDManager.Api.Dtos;
using IDManager.Api.Persistence;
using IDManager.Api.Persistence.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CardsController : ApiControllerBase
{
    private readonly ApplicationDbContext _db;
    private readonly IPdfExtractionService _pdfExtractionService;
    private readonly IPdfGenerationService _pdfGenerationService;
    private readonly ITemplateService _templateService;
    private readonly IUserPointService _pointService;

    public CardsController(
        ApplicationDbContext db,
        IPdfExtractionService pdfExtractionService,
        IPdfGenerationService pdfGenerationService,
        ITemplateService templateService,
        IUserPointService pointService)
    {
        _db = db;
        _pdfExtractionService = pdfExtractionService;
        _pdfGenerationService = pdfGenerationService;
        _templateService = templateService;
        _pointService = pointService;
    }

    // Used by the Admin template designer to preview a sample PDF's extractable fields
    // before defining group boxes - no matching, no points, no card record.
    [Authorize(Roles = "SuperAdmin,Admin")]
    [Consumes("multipart/form-data")]
    [HttpPost("ParsePdf")]
    public IActionResult ParsePdf([FromForm] ParsePdfRequest request)
    {
        if (request.File.Length == 0)
            return BadRequest(ApiResponse.Fail("No file uploaded."));

        using var stream = request.File.OpenReadStream();
        var fields = _pdfExtractionService.ExtractFields(stream);
        return Ok(ApiResponse<List<ExtractedFieldDto>>.Ok(fields));
    }

    // End-user flow: extract the member's PDF, match it against the template's
    // positioned layers, deduct points (pending until Download completes it), and
    // return the merged layers so the Flutter canvas can render a review preview.
    [HttpPost("Generate")]
    public async Task<IActionResult> Generate([FromForm] GenerateCardRequest request)
    {
        if (request.File.Length == 0)
            return BadRequest(ApiResponse.Fail("No file uploaded."));

        var template = await _templateService.GetTemplateAsync(request.TemplateId);
        var user = await _db.Users.FindAsync(CurrentUserId) ?? throw new ArgumentException("User not found.");
        if (user.Points < template.PointCost)
            return BadRequest(ApiResponse.Fail("You don't have enough points. Contact your admin."));

        List<ExtractedFieldDto> extractedFields;
        using (var stream = request.File.OpenReadStream())
            extractedFields = _pdfExtractionService.ExtractFields(stream);

        var (layers, frontImage, backImage) = await _templateService.MatchToTemplateAsync(
            request.TemplateId, request.CombinationId, extractedFields);

        var idCard = new IDCard
        {
            UserId = CurrentUserId,
            TemplateId = request.TemplateId,
            CombinationId = request.CombinationId,
            ExtractedDataJson = JsonSerializer.Serialize(extractedFields),
            PointsDeducted = template.PointCost
        };

        var nameField = extractedFields.FirstOrDefault(f => f.Type == Domain.Enums.LayerFieldType.Text);
        var idCardId = await _pointService.CreateIdCardAsync(idCard, nameField?.Value ?? "Unknown");

        return Ok(ApiResponse<GenerateCardResponse>.Ok(new GenerateCardResponse
        {
            IdCardId = idCardId,
            Layers = layers,
            CardWidthMm = template.CardWidthMm,
            CardHeightMm = template.CardHeightMm,
            FrontImageBase64 = Convert.ToBase64String(frontImage),
            BackImageBase64 = Convert.ToBase64String(backImage)
        }));
    }

    // Renders the final print-ready PDF directly from the template's layer geometry
    // (true vector positions, exact physical card size) and completes the pending
    // points transaction - no client-side screenshotting involved.
    [HttpPost("Download")]
    public async Task<IActionResult> Download([FromBody] DownloadCardPdfRequest request)
    {
        var idCard = await _db.IDCards.FirstOrDefaultAsync(c => c.Id == request.IdCardId)
            ?? throw new ArgumentException("Card not found.");
        if (idCard.UserId != CurrentUserId)
            return Forbid();

        var template = await _templateService.GetTemplateAsync(idCard.TemplateId);
        var extractedFields = JsonSerializer.Deserialize<List<ExtractedFieldDto>>(idCard.ExtractedDataJson) ?? new();

        var (layers, frontImage, backImage) = await _templateService.MatchToTemplateAsync(
            idCard.TemplateId, idCard.CombinationId ?? 0, extractedFields);

        var pdfBytes = _pdfGenerationService.GenerateCardPdf(
            frontImage, backImage, template.CardWidthMm, template.CardHeightMm, layers);

        idCard.GeneratedPdf = pdfBytes;
        await _db.SaveChangesAsync();
        await _pointService.CompletePaymentTransactionAsync(idCard.Id);

        return File(pdfBytes, "application/pdf", $"card-{idCard.Id}.pdf");
    }
}
