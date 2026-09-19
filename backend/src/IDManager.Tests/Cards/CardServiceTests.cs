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

        var result = await service.DownloadAsync(1, 999_999, CancellationToken.None);

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
        var result = await service.DownloadAsync(intruder.Id, cardId, CancellationToken.None);

        Assert.Equal(ResultStatus.Forbidden, result.Status);
    }
}
