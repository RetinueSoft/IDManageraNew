using System.Text.Json;
using IDManager.Domain.Dtos;
using IDManager.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure.Text;

/// One-time conversion of Tamil text saved before the Tamil fix. Those rows hold text in
/// glyph order ("ெபயர்"); everything now works in logical Unicode order ("பெயர்"), so a saved
/// template and the extracted data of past cards must be converted or their keys would no
/// longer match.
///
/// TamilTextNormalizer.GlyphOrderToLogical is not idempotent, so each row carries a
/// TextOrderVersion: 0 = still glyph order, 1 = logical order. Only version 0 rows are
/// converted, and they are marked 1 in the same save - running this again does nothing.
/// New rows are created as version 1 because everything written now is already logical.
public class TextOrderMigrationService(IDManagerDbContext db)
{
    private static readonly JsonSerializerOptions ReadOptions = new() { PropertyNameCaseInsensitive = true };

    /// Returns how many templates and cards were converted.
    public async Task<(int Templates, int Cards)> RunAsync(CancellationToken ct)
    {
        var templates = await db.CardTemplates.Where(t => t.TextOrderVersion == 0).ToListAsync(ct);
        foreach (var template in templates)
        {
            template.LayersJson = ConvertLayers(template.LayersJson);
            template.GroupsJson = ConvertSampleFields(template.GroupsJson) ?? template.GroupsJson;
            template.TextOrderVersion = 1;
        }

        var cards = await db.IDCards.Where(c => c.TextOrderVersion == 0).ToListAsync(ct);
        foreach (var card in cards)
        {
            card.ExtractedDataJson = ConvertExtractedData(card.ExtractedDataJson) ?? card.ExtractedDataJson;
            card.TextOrderVersion = 1;
        }

        await db.SaveChangesAsync(ct);
        return (templates.Count, cards.Count);
    }

    private static string? ConvertLayers(string? json)
    {
        if (string.IsNullOrWhiteSpace(json)) return json;
        var layers = JsonSerializer.Deserialize<List<TemplateLayerDto>>(json, ReadOptions);
        if (layers is null) return json;

        foreach (var group in layers.SelectMany(l => l.Groups))
        {
            group.Name = TamilTextNormalizer.GlyphOrderToLogical(group.Name);
            foreach (var source in group.Sources.Where(s => s.Type == LayerFieldType.Text))
            {
                source.Key = source.Key is null ? null : TamilTextNormalizer.GlyphOrderToLogical(source.Key);
                source.Value = source.Value is null ? null : TamilTextNormalizer.GlyphOrderToLogical(source.Value);
            }
            foreach (var source in group.Sources.Where(s => s.Type == LayerFieldType.Image))
            {
                source.Key = source.Key is null ? null : TamilTextNormalizer.GlyphOrderToLogical(source.Key);
            }
        }

        return JsonSerializer.Serialize(layers);
    }

    private static string? ConvertSampleFields(string? json)
    {
        if (string.IsNullOrWhiteSpace(json)) return json;
        var groups = JsonSerializer.Deserialize<List<FieldGroupDto>>(json, ReadOptions);
        if (groups is null) return json;

        foreach (var group in groups)
        {
            group.Name = TamilTextNormalizer.GlyphOrderToLogical(group.Name);
            ConvertFields(group.Items);
        }

        return JsonSerializer.Serialize(groups);
    }

    private static string? ConvertExtractedData(string? json)
    {
        if (string.IsNullOrWhiteSpace(json) || !json.TrimStart().StartsWith('[')) return json; // "{}" placeholder rows
        var fields = JsonSerializer.Deserialize<List<ExtractedFieldDto>>(json, ReadOptions);
        if (fields is null) return json;

        ConvertFields(fields);
        return JsonSerializer.Serialize(fields);
    }

    private static void ConvertFields(List<ExtractedFieldDto> fields)
    {
        foreach (var field in fields)
        {
            field.Key = field.Key is null ? null : TamilTextNormalizer.GlyphOrderToLogical(field.Key);
            if (field.Type == LayerFieldType.Text)
            {
                field.Value = field.Value is null ? null : TamilTextNormalizer.GlyphOrderToLogical(field.Value);
            }
        }
    }
}
