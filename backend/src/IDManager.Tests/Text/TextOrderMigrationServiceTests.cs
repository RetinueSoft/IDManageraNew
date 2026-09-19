using System.Text.Json;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Text;
using Xunit;

namespace IDManager.Tests.Text;

/// Data saved before the Tamil fix holds text in glyph order ("ெபயர்"). The one-time
/// conversion turns it into logical Unicode order ("பெயர்") and marks each row so it can
/// never be converted twice (the conversion is not idempotent).
public class TextOrderMigrationServiceTests
{
    private const string GlyphOrder = "ெபயர்";   // ெபயர்
    private const string Logical = "பெயர்";      // பெயர்

    private static CardTemplateEntity OldTemplate(int version)
    {
        var layers = new List<TemplateLayerDto>
        {
            new()
            {
                Side = CardSide.Front,
                Groups =
                [
                    new LayerGroupDto
                    {
                        Name = GlyphOrder,
                        Sources =
                        [
                            new LayerSourceItemDto { Key = GlyphOrder, Value = "தந்ைத", Type = LayerFieldType.Text },
                            new LayerSourceItemDto { Key = "image_p1_4", Value = "AAAA", Type = LayerFieldType.Image },
                        ],
                    },
                ],
            },
        };
        var groups = new List<FieldGroupDto>
        {
            new() { Name = "Sample PDF", Items = [new ExtractedFieldDto { Key = GlyphOrder, Value = "x", Type = LayerFieldType.Text }] },
        };
        return new CardTemplateEntity
        {
            Name = "T",
            LayersJson = JsonSerializer.Serialize(layers),
            GroupsJson = JsonSerializer.Serialize(groups),
            TextOrderVersion = version,
            FrontImage = [1], BackImage = [2],
        };
    }

    [Fact]
    public async Task ConvertsATemplatesLayersAndSampleFields_AndMarksItConverted()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        db.CardTemplates.Add(OldTemplate(version: 0));
        await db.SaveChangesAsync();

        await new TextOrderMigrationService(db).RunAsync(CancellationToken.None);

        var template = db.CardTemplates.Single();
        Assert.Equal(1, template.TextOrderVersion);
        var layers = JsonSerializer.Deserialize<List<TemplateLayerDto>>(template.LayersJson!)!;
        var group = layers.Single().Groups.Single();
        Assert.Equal(Logical, group.Name);
        Assert.Equal(Logical, group.Sources[0].Key);
        Assert.Equal("தந்தை", group.Sources[0].Value); // தந்தை
        Assert.Equal("AAAA", group.Sources[1].Value);                               // images are left alone
        var sample = JsonSerializer.Deserialize<List<FieldGroupDto>>(template.GroupsJson)!;
        Assert.Equal(Logical, sample.Single().Items.Single().Key);
    }

    [Fact]
    public async Task ConvertsAPastCardsExtractedData_SoItStillMatchesTheConvertedKeys()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var extracted = new List<ExtractedFieldDto>
        {
            new() { Key = GlyphOrder, Value = "தந்ைத", Type = LayerFieldType.Text },
            new() { Key = "image_p1_1", Value = "BASE64", Type = LayerFieldType.Image },
        };
        db.IDCards.Add(new IDCardEntity { UserId = 1, TemplateId = 1, ExtractedDataJson = JsonSerializer.Serialize(extracted), TextOrderVersion = 0 });
        await db.SaveChangesAsync();

        await new TextOrderMigrationService(db).RunAsync(CancellationToken.None);

        var card = db.IDCards.Single();
        Assert.Equal(1, card.TextOrderVersion);
        var fields = JsonSerializer.Deserialize<List<ExtractedFieldDto>>(card.ExtractedDataJson)!;
        Assert.Equal(Logical, fields[0].Key);
        Assert.Equal("தந்தை", fields[0].Value);
        Assert.Equal("BASE64", fields[1].Value);
    }

    [Fact]
    public async Task NeverConvertsARowTwice()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        // Already logical and marked version 1: converting again would break it.
        var template = OldTemplate(version: 1);
        template.LayersJson = JsonSerializer.Serialize(new List<TemplateLayerDto>
        {
            new() { Side = CardSide.Front, Groups = [new LayerGroupDto { Name = Logical }] },
        });
        db.CardTemplates.Add(template);
        await db.SaveChangesAsync();
        var before = template.LayersJson;

        var service = new TextOrderMigrationService(db);
        await service.RunAsync(CancellationToken.None);
        await service.RunAsync(CancellationToken.None);

        Assert.Equal(before, db.CardTemplates.Single().LayersJson);
    }

    [Fact]
    public async Task RunningTwiceOnAnUnconvertedRow_ConvertsItOnlyOnce()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        db.CardTemplates.Add(OldTemplate(version: 0));
        await db.SaveChangesAsync();

        var service = new TextOrderMigrationService(db);
        await service.RunAsync(CancellationToken.None);
        await service.RunAsync(CancellationToken.None);

        var layers = JsonSerializer.Deserialize<List<TemplateLayerDto>>(db.CardTemplates.Single().LayersJson!)!;
        Assert.Equal(Logical, layers.Single().Groups.Single().Sources[0].Key);
    }

    [Fact]
    public void NewRowsAreBornConverted()
    {
        Assert.Equal(1, new CardTemplateEntity().TextOrderVersion);
        Assert.Equal(1, new IDCardEntity().TextOrderVersion);
    }
}
