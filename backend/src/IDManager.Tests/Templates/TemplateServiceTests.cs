using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Templates;
using Xunit;

namespace IDManager.Tests.Templates;

public class TemplateServiceTests
{
    private static CreateTemplateCommand ValidCommand(string name = "Sample Card") => new()
    {
        Name = name,
        CardWidthMm = 85.6,
        CardHeightMm = 54.0,
        PointCost = 1,
        FrontImageBytes = [1, 2, 3],
        BackImageBytes = [4, 5, 6],
    };

    [Fact]
    public async Task CreateAsync_MissingFields_ReturnsFieldErrors()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);

        var result = await service.CreateAsync(1, new CreateTemplateCommand { Name = "" }, CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Contains("name", result.FieldErrors!.Keys);
        Assert.Contains("frontImage", result.FieldErrors.Keys);
        Assert.Contains("backImage", result.FieldErrors.Keys);
    }

    [Fact]
    public async Task CreateAsync_Valid_PersistsTemplate()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);

        var result = await service.CreateAsync(1, ValidCommand(), CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.True(result.Value!.Id > 0);
        Assert.True(result.Value.IsActive);
    }

    [Fact]
    public async Task SaveLayersAsync_ThenGetTemplate_ReturnsPersistedLayers()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);
        var created = (await service.CreateAsync(1, ValidCommand(), CancellationToken.None)).Value!;

        var layers = new List<TemplateLayerDto>
        {
            new()
            {
                Side = CardSide.Front,
                Groups =
                [
                    new LayerGroupDto { Name = "Name", XMm = 10, YMm = 10 },
                ],
            },
        };
        var saveResult = await service.SaveLayersAsync(
            new SaveLayersRequest { TemplateId = created.Id, Layers = layers },
            CancellationToken.None);
        Assert.Equal(ResultStatus.Success, saveResult.Status);

        var fetched = await service.GetTemplateAsync(created.Id, CancellationToken.None);
        Assert.Equal(ResultStatus.Success, fetched.Status);
        var front = Assert.Single(fetched.Value!.Layers);
        Assert.Equal(CardSide.Front, front.Side);
        Assert.Equal("Name", Assert.Single(front.Groups).Name);
    }

    [Fact]
    public async Task SaveLayersAsync_TemplateNotFound_ReturnsNotFound()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);

        var result = await service.SaveLayersAsync(
            new SaveLayersRequest { TemplateId = 999_999, Layers = [] },
            CancellationToken.None);

        Assert.Equal(ResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task MatchToTemplateAsync_MatchesTextSourcesByKey_CaseAndWhitespaceInsensitive()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);
        var created = (await service.CreateAsync(1, ValidCommand(), CancellationToken.None)).Value!;
        var combination = (await service.AddCombinationAsync(
            new AddCombinationCommand { TemplateId = created.Id, Name = "Default", FrontImageBytes = [1], BackImageBytes = [2] },
            CancellationToken.None)).Value!;

        await service.SaveLayersAsync(new SaveLayersRequest
        {
            TemplateId = created.Id,
            Layers =
            [
                new TemplateLayerDto
                {
                    Side = CardSide.Front,
                    Groups =
                    [
                        new LayerGroupDto
                        {
                            Name = "Name field",
                            XMm = 5,
                            YMm = 5,
                            Sources = [new LayerSourceItemDto { Key = "  Full Name  ", Type = LayerFieldType.Text }],
                        },
                    ],
                },
            ],
        }, CancellationToken.None);

        var extracted = new List<ExtractedFieldDto>
        {
            new() { Key = "full name", Value = "Jane Doe", Type = LayerFieldType.Text },
        };

        var result = await service.MatchToTemplateAsync(created.Id, combination.Id, extracted, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        var group = Assert.Single(result.Value.Layers.Single(l => l.Side == CardSide.Front).Groups);
        Assert.Equal("Jane Doe", group.Sources.Single().Value);
    }

    [Fact]
    public async Task MatchToTemplateAsync_AssignsImageSourcesInExtractionOrder()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);
        var created = (await service.CreateAsync(1, ValidCommand(), CancellationToken.None)).Value!;
        var combination = (await service.AddCombinationAsync(
            new AddCombinationCommand { TemplateId = created.Id, Name = "Default", FrontImageBytes = [1], BackImageBytes = [2] },
            CancellationToken.None)).Value!;

        await service.SaveLayersAsync(new SaveLayersRequest
        {
            TemplateId = created.Id,
            Layers =
            [
                new TemplateLayerDto
                {
                    Side = CardSide.Front,
                    Groups =
                    [
                        new LayerGroupDto { Name = "Photo", XMm = 1, YMm = 1, FieldType = LayerFieldType.Image, Sources = [new LayerSourceItemDto { Type = LayerFieldType.Image }] },
                        new LayerGroupDto { Name = "QR", XMm = 2, YMm = 2, FieldType = LayerFieldType.Image, Sources = [new LayerSourceItemDto { Type = LayerFieldType.Image }] },
                    ],
                },
            ],
        }, CancellationToken.None);

        var extracted = new List<ExtractedFieldDto>
        {
            new() { Value = "aaaa", Type = LayerFieldType.Image },
            new() { Value = "bbbb", Type = LayerFieldType.Image },
        };

        var result = await service.MatchToTemplateAsync(created.Id, combination.Id, extracted, CancellationToken.None);

        var groups = result.Value.Layers.Single(l => l.Side == CardSide.Front).Groups;
        Assert.Equal("aaaa", groups[0].Sources.Single().Value);
        Assert.Equal("bbbb", groups[1].Sources.Single().Value);
    }

    [Fact]
    public async Task MatchToTemplateAsync_UnknownTemplate_ReturnsNotFound()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);

        var result = await service.MatchToTemplateAsync(999_999, 1, [], CancellationToken.None);

        Assert.Equal(ResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task MatchToTemplateAsync_UnknownCombination_ReturnsNotFound()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);
        var created = (await service.CreateAsync(1, ValidCommand(), CancellationToken.None)).Value!;

        var result = await service.MatchToTemplateAsync(created.Id, 999_999, [], CancellationToken.None);

        Assert.Equal(ResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task GetAllAsync_FiltersBySearchTerm()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);
        await service.CreateAsync(1, ValidCommand("Employee Card"), CancellationToken.None);
        await service.CreateAsync(1, ValidCommand("Visitor Pass"), CancellationToken.None);

        var page = await service.GetAllAsync(new PagedRequest { SearchBy = "Employee", PageIndex = 1, PageSize = 20 }, CancellationToken.None);

        Assert.Single(page.Items);
        Assert.Equal("Employee Card", page.Items[0].Name);
    }
}
