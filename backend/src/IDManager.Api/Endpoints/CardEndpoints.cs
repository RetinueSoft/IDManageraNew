using IDManager.Api.Security;
using IDManager.Domain.Dtos;
using IDManager.Infrastructure.Cards;

namespace IDManager.Api.Endpoints;

public static class CardEndpoints
{
    public static void MapCardEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/cards").RequireAuthorization();

        // Used by the SuperAdmin template designer to preview a sample PDF's
        // extractable fields before defining group boxes - no matching, no
        // points, no card record.
        group.MapPost("/parse-pdf", async (HttpRequest request, CardService service, CancellationToken ct) =>
        {
            var form = await request.ReadFormAsync(ct);
            var file = form.Files.GetFile("file");
            if (file is null) return Results.BadRequest(new { error = "No file uploaded." });

            using var ms = new MemoryStream();
            await file.CopyToAsync(ms, ct);
            return Results.Ok(service.ParsePdf(ms.ToArray()));
        }).RequireAuthorization(policy => policy.RequireRole("SuperAdmin")).DisableAntiforgery();

        group.MapPost("/generate", async (HttpRequest request, CardService service, HttpContext http, CancellationToken ct) =>
        {
            var form = await request.ReadFormAsync(ct);
            var file = form.Files.GetFile("file");
            if (file is null) return Results.BadRequest(new { error = "No file uploaded." });

            using var ms = new MemoryStream();
            await file.CopyToAsync(ms, ct);

            // QR slot images arrive as extra files named "qr:<slot key>".
            var qrImages = new List<QrImageDto>();
            foreach (var qrFile in form.Files.Where(f => f.Name.StartsWith("qr:", StringComparison.Ordinal)))
            {
                using var qrStream = new MemoryStream();
                await qrFile.CopyToAsync(qrStream, ct);
                qrImages.Add(new QrImageDto { Key = qrFile.Name[3..], Bytes = qrStream.ToArray() });
            }

            var command = new GenerateCardCommand
            {
                TemplateId = int.TryParse(form["templateId"], out var t) ? t : 0,
                CombinationId = int.TryParse(form["combinationId"], out var c) ? c : 0,
                PdfBytes = ms.ToArray(),
                QrImages = qrImages,
            };

            var result = await service.GenerateAsync(http.User.GetUserId(), command, ct);
            return result.ToHttpResult();
        }).DisableAntiforgery();

        // The body is optional: the card's layers as adjusted on the preview.
        group.MapPost("/{idCardId:int}/download", async (
            int idCardId,
            [Microsoft.AspNetCore.Mvc.FromBody(EmptyBodyBehavior = Microsoft.AspNetCore.Mvc.ModelBinding.EmptyBodyBehavior.Allow)] DownloadCardRequest? request,
            CardService service,
            HttpContext http,
            CancellationToken ct) =>
        {
            var result = await service.DownloadAsync(http.User.GetUserId(), idCardId, request?.Layers, ct);
            return result.ToFileResult("application/pdf", $"card-{idCardId}.pdf");
        });
    }
}
