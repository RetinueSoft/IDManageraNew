using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure;
using IDManager.Infrastructure.Cards;
using IDManager.Infrastructure.Points;
using IDManager.Infrastructure.Templates;
using Xunit;

namespace IDManager.Tests.Cards;

/// Covers CardService's own orchestration/guard clauses (template/user lookup,
/// points check, ownership check) - all of which short-circuit before real PDF
/// parsing, so no actual PDF bytes are needed here. The happy path (real PDF ->
/// extract -> match -> render) is exercised live in manual/integration testing
/// rather than here, since constructing a realistic multi-field PDF fixture isn't
/// worth it for what TemplateServiceTests' MatchToTemplateAsync tests already cover.
public class CardServiceTests
{
    private static CardService NewService(IDManagerDbContext db) => new(
        db,
        new PdfExtractionService(),
        new PdfGenerationService(),
        new TemplateService(db),
        new PointsService(db));

    private static async Task<(int templateId, int combinationId)> CreateTemplateWithCombinationAsync(
        IDManagerDbContext db, int pointCost = 1)
    {
        var templateService = new TemplateService(db);
        var template = (await templateService.CreateAsync(1, new CreateTemplateCommand
        {
            Name = "Card",
            CardWidthMm = 85.6,
            CardHeightMm = 54,
            PointCost = pointCost,
            FrontImageBytes = [1],
            BackImageBytes = [2],
        }, CancellationToken.None)).Value!;

        var combination = (await templateService.AddCombinationAsync(new AddCombinationCommand
        {
            TemplateId = template.Id,
            Name = "Default",
            FrontImageBytes = [1],
            BackImageBytes = [2],
        }, CancellationToken.None)).Value!;

        return (template.Id, combination.Id);
    }

    [Fact]
    public async Task GenerateAsync_UnknownTemplate_ReturnsNotFound()
    {
        using var testDb = TestDb.Create();
        var service = NewService(testDb.Context);

        var result = await service.GenerateAsync(1, new GenerateCardCommand { TemplateId = 999_999, CombinationId = 1, PdfBytes = [] }, CancellationToken.None);

        Assert.Equal(ResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task GenerateAsync_UnknownUser_ReturnsNotFound()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db);

        var service = NewService(db);
        var result = await service.GenerateAsync(999_999, new GenerateCardCommand { TemplateId = templateId, CombinationId = combinationId, PdfBytes = [] }, CancellationToken.None);

        Assert.Equal(ResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task GenerateAsync_InsufficientPoints_ReturnsInvalid_BeforeTouchingPdf()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db, pointCost: 5);
        var user = new UserEntity { Name = "Poor User", Phone = "9700000001", PasswordHash = "x", Role = UserRole.User, Points = 0 };
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var service = NewService(db);
        // Deliberately garbage, non-PDF bytes: if this path reached PdfExtractionService
        // it would throw, so a clean ValidationFailed here proves the points check
        // really does short-circuit before any PDF parsing is attempted.
        var result = await service.GenerateAsync(
            user.Id,
            new GenerateCardCommand { TemplateId = templateId, CombinationId = combinationId, PdfBytes = [0xFF, 0x00, 0x01] },
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
    }

    [Fact]
    public async Task DownloadAsync_UnknownCard_ReturnsNotFound()
    {
        using var testDb = TestDb.Create();
        var service = NewService(testDb.Context);

        var result = await service.DownloadAsync(1, 999_999, null, CancellationToken.None);

        Assert.Equal(ResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task DownloadAsync_CardBelongsToAnotherUser_ReturnsForbidden()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db);
        var owner = new UserEntity { Name = "Owner", Phone = "9700000002", PasswordHash = "x", Role = UserRole.User };
        var intruder = new UserEntity { Name = "Intruder", Phone = "9700000003", PasswordHash = "x", Role = UserRole.User };
        db.Users.AddRange(owner, intruder);
        await db.SaveChangesAsync();

        db.IDCards.Add(new IDCardEntity
        {
            UserId = owner.Id,
            TemplateId = templateId,
            CombinationId = combinationId,
            ExtractedDataJson = "[]",
        });
        await db.SaveChangesAsync();
        var cardId = db.IDCards.Single().Id;

        var service = NewService(db);
        var result = await service.DownloadAsync(intruder.Id, cardId, null, CancellationToken.None);

        Assert.Equal(ResultStatus.Forbidden, result.Status);
    }

    // ---- points on card generation (docs/member-hierarchy.md, section 5) ----

    // A 1x1 PNG, used to render a real (empty) PDF as the member's source document.
    private static readonly byte[] Png = Convert.FromBase64String(
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==");

    private static byte[] ValidPdf() => new PdfGenerationService().GenerateCardPdf(Png, Png, 85.6, 54, []);

    [Fact]
    public async Task GenerateAsync_SuperAdminWithNoPoints_IsNotBlocked_AndTheirBalanceStaysUnchanged()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db, pointCost: 5);
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin, points: 0);

        var service = NewService(db);
        var result = await service.GenerateAsync(
            sa.Id,
            new GenerateCardCommand { TemplateId = templateId, CombinationId = combinationId, PdfBytes = ValidPdf() },
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        // The SuperAdmin pays and receives the same amount, so the net is zero.
        await new PointsService(db).CompletePaymentTransactionAsync(result.Value!.IdCardId, CancellationToken.None);
        Assert.Equal(0, sa.Points);
    }

    [Fact]
    public async Task GenerateAsync_MemberPays_AndTheSuperAdminReceives_NotTheParent()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db, pointCost: 3);
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var distributor = await TestUsers.AddAsync(db, "D", UserRole.Distributor, sa, points: 50);
        var retailer = await TestUsers.AddAsync(db, "R", UserRole.Retailer, distributor, points: 20);

        var service = NewService(db);
        var result = await service.GenerateAsync(
            retailer.Id,
            new GenerateCardCommand { TemplateId = templateId, CombinationId = combinationId, PdfBytes = ValidPdf() },
            CancellationToken.None);
        Assert.Equal(ResultStatus.Success, result.Status);

        await new PointsService(db).CompletePaymentTransactionAsync(result.Value!.IdCardId, CancellationToken.None);

        Assert.Equal(17, retailer.Points);   // paid 3
        Assert.Equal(3, sa.Points);          // received 3
        Assert.Equal(50, distributor.Points); // the parent gets nothing
    }

    // ---- adjusted layers on download ----

    private static string PdfText(byte[] pdf)
    {
        using var doc = UglyToad.PdfPig.PdfDocument.Open(pdf);
        return string.Join(" ", doc.GetPages().Select(p => p.Text));
    }

    private static TemplateLayerDto TextLayer(string value) => new()
    {
        Side = CardSide.Front,
        Groups =
        [
            new LayerGroupDto
            {
                Name = "Adjusted",
                FieldType = LayerFieldType.Text,
                XMm = 5,
                YMm = 5,
                Sources = [new LayerSourceItemDto { Value = value, Type = LayerFieldType.Text }],
            },
        ],
    };

    [Fact]
    public async Task DownloadAsync_WithAdjustedLayers_PrintsThoseInsteadOfTheTemplateLayers()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db);
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var service = NewService(db);
        var generated = await service.GenerateAsync(
            sa.Id,
            new GenerateCardCommand { TemplateId = templateId, CombinationId = combinationId, PdfBytes = ValidPdf() },
            CancellationToken.None);

        var download = await service.DownloadAsync(sa.Id, generated.Value!.IdCardId, [TextLayer("ADJUSTED VALUE")], CancellationToken.None);

        Assert.Equal(ResultStatus.Success, download.Status);
        Assert.Contains("ADJUSTED VALUE", PdfText(download.Value!));
    }

    [Fact]
    public async Task DownloadAsync_WithAnEmptyLayerList_PrintsNoLayers()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db);
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var service = NewService(db);
        var generated = await service.GenerateAsync(
            sa.Id,
            new GenerateCardCommand { TemplateId = templateId, CombinationId = combinationId, PdfBytes = ValidPdf() },
            CancellationToken.None);

        var download = await service.DownloadAsync(sa.Id, generated.Value!.IdCardId, [], CancellationToken.None);

        Assert.Equal(ResultStatus.Success, download.Status);
        Assert.Equal("", PdfText(download.Value!).Trim());
    }

    // ---- QR images are read and regenerated ----

    private static byte[] QrUpload(string text)
    {
        // A smaller, softer copy of a QR - the kind of image a user might upload.
        var sharp = QrCodeRegenerator.Render(text, ZXing.QrCode.Internal.ErrorCorrectionLevel.M);
        using var source = SkiaSharp.SKBitmap.Decode(sharp);
        using var small = new SkiaSharp.SKBitmap(260, 260);
        using (var canvas = new SkiaSharp.SKCanvas(small))
        {
            using var paint = new SkiaSharp.SKPaint { FilterQuality = SkiaSharp.SKFilterQuality.High };
            canvas.DrawBitmap(source, new SkiaSharp.SKRect(0, 0, 260, 260), paint);
        }
        using var image = SkiaSharp.SKImage.FromBitmap(small);
        return image.Encode(SkiaSharp.SKEncodedImageFormat.Png, 100).ToArray();
    }

    [Fact]
    public async Task GenerateAsync_ReplacesAnUploadedQrWithOneItGeneratesFromItsContent()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db);
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var upload = QrUpload("member-42");

        var result = await NewService(db).GenerateAsync(
            sa.Id,
            new GenerateCardCommand
            {
                TemplateId = templateId,
                CombinationId = combinationId,
                PdfBytes = ValidPdf(),
                QrImages = [new QrImageDto { Key = "QR 1", Bytes = upload }],
            },
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        var stored = System.Text.Json.JsonSerializer.Deserialize<List<ExtractedFieldDto>>(db.IDCards.Single().ExtractedDataJson)!;
        var qr = Assert.Single(stored, f => f.Key == "QR 1");
        var storedBytes = Convert.FromBase64String(qr.Value!);
        Assert.NotEqual(upload, storedBytes);
        Assert.Equal("member-42", QrCodeRegenerator.Read(storedBytes)?.Text);
    }

    [Fact]
    public async Task GenerateAsync_AnUnreadableQrImage_IsRefused_WithoutCreatingACard()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db);
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);

        var result = await NewService(db).GenerateAsync(
            sa.Id,
            new GenerateCardCommand
            {
                TemplateId = templateId,
                CombinationId = combinationId,
                PdfBytes = ValidPdf(),
                QrImages = [new QrImageDto { Key = "QR 1", Bytes = Png }],
            },
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Contains("QR 1", result.Error);
        Assert.Empty(db.IDCards);
    }
}
