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

    [Fact]
    public async Task MatchToTemplateAsync_FillsQrLayersByKey_WithoutTakingThePdfImages()
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
                        // Declared first, so a naive "next image" assignment would give it the photo.
                        new LayerGroupDto
                        {
                            Name = "QR 1", FieldType = LayerFieldType.Image, IsQr = true,
                            Sources = [new LayerSourceItemDto { Key = "QR 1", Type = LayerFieldType.Image }],
                        },
                        new LayerGroupDto
                        {
                            Name = "Photo", FieldType = LayerFieldType.Image,
                            Sources = [new LayerSourceItemDto { Type = LayerFieldType.Image }],
                        },
                    ],
                },
            ],
        }, CancellationToken.None);

        var extracted = new List<ExtractedFieldDto>
        {
            new() { Key = "image_p1_1", Value = "PHOTO", Type = LayerFieldType.Image },
            new() { Key = "QR 1", Value = "QRIMAGE", Type = LayerFieldType.Image },
        };

        var result = await service.MatchToTemplateAsync(created.Id, combination.Id, extracted, CancellationToken.None);

        var groups = result.Value.Layers.Single(l => l.Side == CardSide.Front).Groups;
        Assert.Equal("QRIMAGE", groups.Single(g => g.IsQr).Sources.Single().Value);
        Assert.Equal("PHOTO", groups.Single(g => !g.IsQr).Sources.Single().Value);
    }

    [Fact]
    public async Task MatchToTemplateAsync_QrLayerWithNoPickedImage_StaysEmpty()
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
                            Name = "QR 1", FieldType = LayerFieldType.Image, IsQr = true,
                            Sources = [new LayerSourceItemDto { Key = "QR 1", Type = LayerFieldType.Image }],
                        },
                    ],
                },
            ],
        }, CancellationToken.None);

        // The member's PDF has a photo, but no QR image was picked.
        var extracted = new List<ExtractedFieldDto>
        {
            new() { Key = "image_p1_1", Value = "PHOTO", Type = LayerFieldType.Image },
        };

        var result = await service.MatchToTemplateAsync(created.Id, combination.Id, extracted, CancellationToken.None);

        var qr = result.Value.Layers.Single(l => l.Side == CardSide.Front).Groups.Single();
        Assert.True(string.IsNullOrEmpty(qr.Sources.Single().Value));
    }

    [Fact]
    public async Task MatchToTemplateAsync_WithoutACombination_UsesTheTemplatesOwnImages()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);
        var created = (await service.CreateAsync(1, ValidCommand(), CancellationToken.None)).Value!;

        var result = await service.MatchToTemplateAsync(created.Id, 0, [], CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.Equal(new byte[] { 1, 2, 3 }, result.Value.FrontImage);
        Assert.Equal(new byte[] { 4, 5, 6 }, result.Value.BackImage);
    }

    [Fact]
    public async Task MatchToTemplateAsync_UnknownCombination_IsStillNotFound()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);
        var created = (await service.CreateAsync(1, ValidCommand(), CancellationToken.None)).Value!;

        var result = await service.MatchToTemplateAsync(created.Id, 999_999, [], CancellationToken.None);

        Assert.Equal(ResultStatus.NotFound, result.Status);
    }

    [Fact]
    public async Task UpdateAsync_ChangesTheCardSize_AndKeepsWhatItWasNotGiven()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);
        var created = (await service.CreateAsync(1, ValidCommand(), CancellationToken.None)).Value!;
        await service.SaveLayersAsync(new SaveLayersRequest
        {
            TemplateId = created.Id,
            Layers = [],
            Groups = [new FieldGroupDto { Name = "Sample PDF", Items = [new ExtractedFieldDto { Key = "Name", Value = "Jane" }] }],
        }, CancellationToken.None);

        var result = await service.UpdateAsync(new UpdateTemplateCommand
        {
            Id = created.Id,
            Name = "Renamed",
            PointCost = 2,
            IsActive = true,
            CardWidthMm = 100,
            CardHeightMm = 60,
            // GroupsJson deliberately not given: the sample-PDF fields must survive an edit.
        }, CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.Equal(100, result.Value!.CardWidthMm);
        Assert.Equal(60, result.Value.CardHeightMm);
        var group = Assert.Single(result.Value.Groups);
        Assert.Equal("Name", Assert.Single(group.Items).Key);
    }

    [Fact]
    public async Task UpdateAsync_WithoutASize_LeavesTheSizeUnchanged()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);
        var created = (await service.CreateAsync(1, ValidCommand(), CancellationToken.None)).Value!;

        var result = await service.UpdateAsync(
            new UpdateTemplateCommand { Id = created.Id, Name = "Same size", PointCost = 1, IsActive = true },
            CancellationToken.None);

        Assert.Equal(85.6, result.Value!.CardWidthMm);
        Assert.Equal(54.0, result.Value.CardHeightMm);
    }

    [Theory]
    [InlineData(0, 54)]
    [InlineData(85.6, -1)]
    public async Task UpdateAsync_NonPositiveSize_IsRejected(double width, double height)
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);
        var created = (await service.CreateAsync(1, ValidCommand(), CancellationToken.None)).Value!;

        var result = await service.UpdateAsync(new UpdateTemplateCommand
        {
            Id = created.Id, Name = "X", PointCost = 1, IsActive = true, CardWidthMm = width, CardHeightMm = height,
        }, CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.True(result.FieldErrors!.ContainsKey("cardWidthMm") || result.FieldErrors.ContainsKey("cardHeightMm"));
        Assert.Equal(85.6, (await service.GetTemplateAsync(created.Id, CancellationToken.None)).Value!.CardWidthMm);
    }

    [Fact]
    public async Task CreateAsync_NonPositiveSize_ReturnsFieldErrors()
    {
        using var testDb = TestDb.Create();
        var service = new TemplateService(testDb.Context);
        var command = ValidCommand();
        command.CardWidthMm = 0;

        var result = await service.CreateAsync(1, command, CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
        Assert.Contains("cardWidthMm", result.FieldErrors!.Keys);
    }

    [Fact]
    public async Task MatchToTemplateAsync_ImageLayers_AreMatchedByKeyBeforeExtractionOrder()
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
                        // Imported from the sample PDF, where the photo was its 4th image.
                        new LayerGroupDto
                        {
                            Name = "photo", FieldType = LayerFieldType.Image,
                            Sources = [new LayerSourceItemDto { Key = "image_p1_4", Type = LayerFieldType.Image }],
                        },
                        // No key: takes whatever image is left.
                        new LayerGroupDto
                        {
                            Name = "other", FieldType = LayerFieldType.Image,
                            Sources = [new LayerSourceItemDto { Type = LayerFieldType.Image }],
                        },
                    ],
                },
            ],
        }, CancellationToken.None);

        // The member's PDF lists a black mask first and the real photo fourth.
        var extracted = new List<ExtractedFieldDto>
        {
            new() { Key = "image_p1_1", Value = "BLACK", Type = LayerFieldType.Image },
            new() { Key = "image_p1_2", Value = "MASK", Type = LayerFieldType.Image },
            new() { Key = "image_p1_4", Value = "PHOTO", Type = LayerFieldType.Image },
        };

        var result = await service.MatchToTemplateAsync(created.Id, combination.Id, extracted, CancellationToken.None);

        var groups = result.Value.Layers.Single(l => l.Side == CardSide.Front).Groups;
        Assert.Equal("PHOTO", groups.Single(g => g.Name == "photo").Sources.Single().Value);  // by key, not the first image
        Assert.Equal("BLACK", groups.Single(g => g.Name == "other").Sources.Single().Value);  // the photo is not handed out twice
    }

    [Fact]
    public async Task MatchToTemplateAsync_ImageLayerWhoseKeyIsNotInTheMembersPdf_FallsBackToExtractionOrder()
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
                            Name = "photo", FieldType = LayerFieldType.Image,
                            Sources = [new LayerSourceItemDto { Key = "image_p9_9", Type = LayerFieldType.Image }],
                        },
                    ],
                },
            ],
        }, CancellationToken.None);

        var extracted = new List<ExtractedFieldDto> { new() { Key = "image_p1_1", Value = "FIRST", Type = LayerFieldType.Image } };

        var result = await service.MatchToTemplateAsync(created.Id, combination.Id, extracted, CancellationToken.None);

        Assert.Equal("FIRST", result.Value.Layers.Single().Groups.Single().Sources.Single().Value);
    }
}
