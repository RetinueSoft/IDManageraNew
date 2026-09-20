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

        var result = await service.DownloadAsync(1, 999_999, null, null, CancellationToken.None);

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
        var result = await service.DownloadAsync(intruder.Id, cardId, null, null, CancellationToken.None);

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

        var download = await service.DownloadAsync(sa.Id, generated.Value!.IdCardId, [TextLayer("ADJUSTED VALUE")], null, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, download.Status);
        Assert.Contains("ADJUSTED VALUE", PdfText(download.Value!.Pdf));
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

        var download = await service.DownloadAsync(sa.Id, generated.Value!.IdCardId, [], null, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, download.Status);
        Assert.Equal("", PdfText(download.Value!.Pdf).Trim());
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

    // ---- switching the background after previewing ----

    [Fact]
    public async Task DownloadAsync_WithAnotherBackgroundOfTheTemplate_PrintsOnThatBackground()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, defaultCombinationId) = await CreateTemplateWithCombinationAsync(db);
        var other = (await new TemplateService(db).AddCombinationAsync(new AddCombinationCommand
        {
            TemplateId = templateId,
            Name = "Blue",
            FrontImageBytes = Png,
            BackImageBytes = Png,
        }, CancellationToken.None)).Value!;
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var service = NewService(db);
        var generated = await service.GenerateAsync(
            sa.Id,
            new GenerateCardCommand { TemplateId = templateId, CombinationId = defaultCombinationId, PdfBytes = ValidPdf() },
            CancellationToken.None);

        var download = await service.DownloadAsync(sa.Id, generated.Value!.IdCardId, null, other.Id, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, download.Status);
        Assert.Equal(other.Id, db.IDCards.Single().CombinationId);
    }

    [Fact]
    public async Task DownloadAsync_BackgroundZero_MeansTheTemplatesOwnImages()
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

        var download = await service.DownloadAsync(sa.Id, generated.Value!.IdCardId, null, 0, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, download.Status);
        Assert.Null(db.IDCards.Single().CombinationId);
    }

    [Fact]
    public async Task DownloadAsync_ABackgroundOfAnotherTemplate_IsRefused()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db);
        var (_, foreignCombinationId) = await CreateTemplateWithCombinationAsync(db);
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var service = NewService(db);
        var generated = await service.GenerateAsync(
            sa.Id,
            new GenerateCardCommand { TemplateId = templateId, CombinationId = combinationId, PdfBytes = ValidPdf() },
            CancellationToken.None);

        var download = await service.DownloadAsync(sa.Id, generated.Value!.IdCardId, null, foreignCombinationId, CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, download.Status);
        Assert.Equal(combinationId, db.IDCards.Single().CombinationId);
    }

    // ---- the downloaded file's name ----

    private static async Task<(CardService service, IDManagerDbContext db, int userId, int idCardId, int templateId)> GeneratedCardAsync(
        TestDb testDb, string? pattern, params ExtractedFieldDto[] extra)
    {
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db);
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        var template = db.CardTemplates.Single();
        template.FileNamePattern = pattern;
        await db.SaveChangesAsync();

        var service = NewService(db);
        var generated = await service.GenerateAsync(
            sa.Id,
            new GenerateCardCommand { TemplateId = templateId, CombinationId = combinationId, PdfBytes = ValidPdf() },
            CancellationToken.None);
        var card = db.IDCards.Single();
        card.ExtractedDataJson = System.Text.Json.JsonSerializer.Serialize(extra.ToList());
        await db.SaveChangesAsync();
        return (service, db, sa.Id, generated.Value!.IdCardId, templateId);
    }

    private static ExtractedFieldDto Field(string key, string value) =>
        new() { Key = key, Value = value, Type = LayerFieldType.Text };

    [Fact]
    public async Task DownloadAsync_IsNamedFromTheTemplatesPatternAndTheMembersFields()
    {
        using var testDb = TestDb.Create();
        var (service, _, userId, cardId, _) = await GeneratedCardAsync(
            testDb, "{Name} - {Card No}", Field("Name", "Ravi Kumar"), Field("Card No", "1234567890"));

        var download = await service.DownloadAsync(userId, cardId, null, null, CancellationToken.None);

        Assert.Equal("Ravi Kumar - 1234567890", download.Value!.FileName);
    }

    [Fact]
    public async Task DownloadAsync_WithoutAPattern_IsNamedAfterTheCard()
    {
        using var testDb = TestDb.Create();
        var (service, _, userId, cardId, _) = await GeneratedCardAsync(testDb, null, Field("Name", "Ravi"));

        var download = await service.DownloadAsync(userId, cardId, null, null, CancellationToken.None);

        Assert.Equal($"card-{cardId}", download.Value!.FileName);
    }

    [Fact]
    public async Task DownloadAsync_WhenThePatternsFieldsAreNotInThePdf_IsNamedAfterTheCard()
    {
        using var testDb = TestDb.Create();
        var (service, _, userId, cardId, _) = await GeneratedCardAsync(testDb, "{Name}", Field("Other", "x"));

        var download = await service.DownloadAsync(userId, cardId, null, null, CancellationToken.None);

        Assert.Equal($"card-{cardId}", download.Value!.FileName);
    }

    [Fact]
    public async Task DownloadAsync_AValueCorrectedOnThePreviewNamesTheFile()
    {
        using var testDb = TestDb.Create();
        var (service, _, userId, cardId, _) = await GeneratedCardAsync(testDb, "{Name}", Field("Name", "Ravi Kumr"));
        var corrected = new TemplateLayerDto
        {
            Side = CardSide.Front,
            Groups =
            [
                new LayerGroupDto
                {
                    Name = "Name",
                    Sources = [new LayerSourceItemDto { Key = "Name", Value = "Ravi Kumar", Type = LayerFieldType.Text }],
                },
            ],
        };

        var download = await service.DownloadAsync(userId, cardId, [corrected], null, CancellationToken.None);

        Assert.Equal("Ravi Kumar", download.Value!.FileName);
    }

    [Fact]
    public async Task DownloadAsync_AFieldReadUnderAnotherKeyStillNamesTheFile()
    {
        using var testDb = TestDb.Create();
        var (service, _, userId, cardId, _) = await GeneratedCardAsync(testDb, "{Name}");
        var layer = new TemplateLayerDto
        {
            Side = CardSide.Front,
            Groups =
            [
                new LayerGroupDto
                {
                    Name = "Value only",
                    // The layer shows just the value (no label) but reads it from the "Name" PDF field.
                    Sources = [new LayerSourceItemDto { SourceKey = "Name", Value = "Meena", Type = LayerFieldType.Text }],
                },
            ],
        };

        var download = await service.DownloadAsync(userId, cardId, [layer], null, CancellationToken.None);

        Assert.Equal("Meena", download.Value!.FileName);
    }

    // ---- the points history names the card like the file ----

    private static List<string> Reasons(IDManagerDbContext db) =>
        db.PointTransactions.Where(t => t.ForIdCardId != null).OrderBy(t => t.Id).Select(t => t.Reason).ToList();

    /// A member PDF whose rows read "Name | Ravi Kumar" and "Card No | 1234567890" - the label and
    /// the value far enough apart to be two cells, which is how the extractor finds a field.
    private static byte[] MemberPdf()
    {
        static LayerGroupDto Cell(double x, double y, string text) => new()
        {
            Name = text, XMm = x, YMm = y, WidthMm = 30, Sources = [new LayerSourceItemDto { Value = text }],
        };

        return new PdfGenerationService().GenerateCardPdf(
            Png, Png, 85.6, 54,
            [
                new TemplateLayerDto
                {
                    Side = CardSide.Front,
                    Groups = [Cell(5, 5, "Name"), Cell(45, 5, "Ravi Kumar"), Cell(5, 15, "Card No"), Cell(45, 15, "1234567890")],
                },
            ]);
    }

    [Fact]
    public async Task GenerateAsync_TheCardIsNamedInThePointsHistoryLikeItsFile()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db);
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);
        db.CardTemplates.Single().FileNamePattern = "{Name} - {Card No}";
        await db.SaveChangesAsync();
        // The template must have the fields as layers for a value to be matched, but the extracted
        // PDF fields alone are enough for the name.
        var result = await NewService(db).GenerateAsync(
            sa.Id,
            new GenerateCardCommand { TemplateId = templateId, CombinationId = combinationId, PdfBytes = MemberPdf() },
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.All(Reasons(db), reason => Assert.EndsWith("for Ravi Kumar - 1234567890", reason));
        Assert.Equal(2, Reasons(db).Count);
    }

    [Fact]
    public async Task GenerateAsync_WithoutAPattern_TheHistoryStillUsesTheFirstFieldValue()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db);
        var sa = await TestUsers.AddAsync(db, "SA", UserRole.SuperAdmin);

        await NewService(db).GenerateAsync(
            sa.Id,
            new GenerateCardCommand { TemplateId = templateId, CombinationId = combinationId, PdfBytes = MemberPdf() },
            CancellationToken.None);

        Assert.All(Reasons(db), reason => Assert.EndsWith("for Ravi Kumar", reason));
    }

    [Fact]
    public async Task DownloadAsync_RenamesTheHistoryToTheFileNameActuallySaved()
    {
        using var testDb = TestDb.Create();
        var (service, db, userId, cardId, _) = await GeneratedCardAsync(
            testDb, "{Name}", Field("Name", "Ravi Kumr"));
        var corrected = new TemplateLayerDto
        {
            Side = CardSide.Front,
            Groups = [new LayerGroupDto { Name = "n", Sources = [new LayerSourceItemDto { Key = "Name", Value = "Ravi Kumar", Type = LayerFieldType.Text }] }],
        };

        var download = await service.DownloadAsync(userId, cardId, [corrected], null, CancellationToken.None);

        Assert.Equal("Ravi Kumar", download.Value!.FileName);
        Assert.Equal(2, Reasons(db).Count);
        Assert.All(Reasons(db), reason => Assert.EndsWith("for Ravi Kumar", reason));
    }

    [Fact]
    public async Task DownloadAsync_WithoutAPattern_TheHistoryUsesTheCardFileName()
    {
        using var testDb = TestDb.Create();
        var (service, db, userId, cardId, _) = await GeneratedCardAsync(testDb, null, Field("Name", "Ravi"));

        await service.DownloadAsync(userId, cardId, null, null, CancellationToken.None);

        Assert.All(Reasons(db), reason => Assert.EndsWith($"for card-{cardId}", reason));
    }

    [Fact]
    public async Task TheEarnRow_KeepsWhoGeneratedTheCard()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var (templateId, combinationId) = await CreateTemplateWithCombinationAsync(db, pointCost: 2);
        var sa = await TestUsers.AddAsync(db, "The Admin", UserRole.SuperAdmin);
        var retailer = await TestUsers.AddAsync(db, "Priya", UserRole.Retailer, sa, points: 10);
        db.CardTemplates.Single().FileNamePattern = "{Name}";
        await db.SaveChangesAsync();
        var service = NewService(db);
        var generated = await service.GenerateAsync(
            retailer.Id,
            new GenerateCardCommand { TemplateId = templateId, CombinationId = combinationId, PdfBytes = MemberPdf() },
            CancellationToken.None);

        await service.DownloadAsync(retailer.Id, generated.Value!.IdCardId, null, null, CancellationToken.None);

        var reasons = Reasons(db);
        Assert.Contains("Card generated for Ravi Kumar", reasons);
        Assert.Contains("Card generated by Priya for Ravi Kumar", reasons);
    }
}
