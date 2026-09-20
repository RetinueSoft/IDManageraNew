using System.Text.Json;
using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure.Templates;

public class TemplateService(IDManagerDbContext db)
{
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };

    public async Task<PagedResult<TemplateSummaryDto>> GetAllAsync(PagedRequest request, CancellationToken ct)
    {
        var query = db.CardTemplates.AsQueryable();
        if (!string.IsNullOrWhiteSpace(request.SearchBy))
        {
            query = query.Where(t => t.Name.Contains(request.SearchBy));
        }

        var totalCount = await query.CountAsync(ct);
        var items = await query
            .OrderByDescending(t => t.CreatedAt)
            .Skip((request.PageIndex - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(ct);

        return new PagedResult<TemplateSummaryDto>
        {
            Items = items.Select(ToSummaryDto).ToList(),
            TotalCount = totalCount,
            PageIndex = request.PageIndex,
            PageSize = request.PageSize,
        };
    }

    public async Task<OperationResult<TemplateDetailDto>> GetTemplateAsync(int id, CancellationToken ct)
    {
        var template = await db.CardTemplates.Include(t => t.Combinations).FirstOrDefaultAsync(t => t.Id == id, ct);
        return template is null
            ? OperationResult<TemplateDetailDto>.NotFound("Template not found.")
            : OperationResult<TemplateDetailDto>.Success(ToDetailDto(template));
    }

    public async Task<OperationResult<TemplateDetailDto>> CreateAsync(int createdById, CreateTemplateCommand command, CancellationToken ct)
    {
        var errors = new Dictionary<string, string>();
        if (string.IsNullOrWhiteSpace(command.Name)) errors["name"] = "Name is required.";
        if (command.FrontImageBytes.Length == 0) errors["frontImage"] = "Front image is required.";
        if (command.BackImageBytes.Length == 0) errors["backImage"] = "Back image is required.";
        if (command.CardWidthMm <= 0) errors["cardWidthMm"] = "Width must be greater than 0.";
        if (command.CardHeightMm <= 0) errors["cardHeightMm"] = "Height must be greater than 0.";
        if (errors.Count > 0) return OperationResult<TemplateDetailDto>.Invalid(errors);

        var template = new CardTemplateEntity
        {
            Name = command.Name,
            CardWidthMm = command.CardWidthMm,
            CardHeightMm = command.CardHeightMm,
            PointCost = command.PointCost,
            GroupsJson = command.GroupsJson,
            IsActive = true,
            CreatedById = createdById,
            FrontImage = command.FrontImageBytes,
            BackImage = command.BackImageBytes,
        };

        db.CardTemplates.Add(template);
        await db.SaveChangesAsync(ct);

        return OperationResult<TemplateDetailDto>.Success(ToDetailDto(template));
    }

    public async Task<OperationResult<TemplateDetailDto>> UpdateAsync(UpdateTemplateCommand command, CancellationToken ct)
    {
        var template = await db.CardTemplates.Include(t => t.Combinations).FirstOrDefaultAsync(t => t.Id == command.Id, ct);
        if (template is null) return OperationResult<TemplateDetailDto>.NotFound("Template not found.");

        if (string.IsNullOrWhiteSpace(command.Name))
        {
            return OperationResult<TemplateDetailDto>.Invalid(new Dictionary<string, string> { ["name"] = "Name is required." });
        }

        var sizeErrors = new Dictionary<string, string>();
        if (command.CardWidthMm is <= 0) sizeErrors["cardWidthMm"] = "Width must be greater than 0.";
        if (command.CardHeightMm is <= 0) sizeErrors["cardHeightMm"] = "Height must be greater than 0.";
        if (sizeErrors.Count > 0) return OperationResult<TemplateDetailDto>.Invalid(sizeErrors);

        template.Name = command.Name;
        template.PointCost = command.PointCost;
        template.IsActive = command.IsActive;
        if (command.CardWidthMm is { } width) template.CardWidthMm = width;
        if (command.CardHeightMm is { } height) template.CardHeightMm = height;
        if (command.GroupsJson is not null) template.GroupsJson = command.GroupsJson;
        template.ModifiedAt = DateTime.UtcNow;
        if (command.FrontImageBytes is { Length: > 0 }) template.FrontImage = command.FrontImageBytes;
        if (command.BackImageBytes is { Length: > 0 }) template.BackImage = command.BackImageBytes;

        await db.SaveChangesAsync(ct);
        return OperationResult<TemplateDetailDto>.Success(ToDetailDto(template));
    }

    public async Task<OperationResult> SetActiveAsync(int id, bool active, CancellationToken ct)
    {
        var template = await db.CardTemplates.FindAsync([id], ct);
        if (template is null) return OperationResult.NotFound("Template not found.");

        template.IsActive = active;
        template.ModifiedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return OperationResult.Success();
    }

    public async Task<OperationResult> SaveLayersAsync(SaveLayersRequest request, CancellationToken ct)
    {
        var template = await db.CardTemplates.FindAsync([request.TemplateId], ct);
        if (template is null) return OperationResult.NotFound("Template not found.");

        template.LayersJson = JsonSerializer.Serialize(request.Layers);
        if (request.Groups is not null) template.GroupsJson = JsonSerializer.Serialize(request.Groups);
        if (request.FileNamePattern is not null)
        {
            template.FileNamePattern = string.IsNullOrWhiteSpace(request.FileNamePattern) ? null : request.FileNamePattern.Trim();
        }
        template.ModifiedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return OperationResult.Success();
    }

    public async Task<OperationResult<CombinationDto>> AddCombinationAsync(AddCombinationCommand command, CancellationToken ct)
    {
        var template = await db.CardTemplates.FindAsync([command.TemplateId], ct);
        if (template is null) return OperationResult<CombinationDto>.NotFound("Template not found.");
        if (string.IsNullOrWhiteSpace(command.Name)) return OperationResult<CombinationDto>.Invalid("Give the background a name.");
        if (command.FrontImageBytes.Length == 0 || command.BackImageBytes.Length == 0)
        {
            return OperationResult<CombinationDto>.Invalid("A background needs both a front and a back image.");
        }

        var combination = new TemplateCombinationEntity
        {
            TemplateId = template.Id,
            Name = command.Name,
            FrontImage = command.FrontImageBytes,
            BackImage = command.BackImageBytes,
        };

        db.TemplateCombinations.Add(combination);
        await db.SaveChangesAsync(ct);

        return OperationResult<CombinationDto>.Success(ToCombinationDto(combination));
    }

    public async Task<OperationResult> DeleteCombinationAsync(int combinationId, CancellationToken ct)
    {
        var combination = await db.TemplateCombinations.FindAsync([combinationId], ct);
        if (combination is null) return OperationResult.NotFound("Combination not found.");

        db.TemplateCombinations.Remove(combination);
        await db.SaveChangesAsync(ct);
        return OperationResult.Success();
    }

    /// Matches a member's extracted PDF fields against the template's positioned
    /// layers by key, filling each layer source's value so the result can be
    /// rendered/printed directly at its designed position.
    public async Task<OperationResult<(List<TemplateLayerDto> Layers, byte[] FrontImage, byte[] BackImage)>> MatchToTemplateAsync(
        int templateId, int combinationId, List<ExtractedFieldDto> extractedFields, CancellationToken ct)
    {
        var template = await db.CardTemplates.FindAsync([templateId], ct);
        if (template is null)
        {
            return OperationResult<(List<TemplateLayerDto>, byte[], byte[])>.NotFound("Template not found.");
        }

        // A template without combinations (or a card generated without picking one) uses
        // the template's own front and back images.
        var frontImage = template.FrontImage;
        var backImage = template.BackImage;
        if (combinationId > 0)
        {
            var combination = await db.TemplateCombinations.FindAsync([combinationId], ct);
            if (combination is null)
            {
                return OperationResult<(List<TemplateLayerDto>, byte[], byte[])>.NotFound("Combination not found.");
            }
            frontImage = combination.FrontImage;
            backImage = combination.BackImage;
        }

        var layers = template.LayersJson != null
            ? JsonSerializer.Deserialize<List<TemplateLayerDto>>(template.LayersJson, JsonOptions) ?? []
            : [];

        MergeExtractedValues(layers, extractedFields);

        return OperationResult<(List<TemplateLayerDto>, byte[], byte[])>.Success((layers, frontImage, backImage));
    }

    /// The PDF field a source reads: its SourceKey if it has one, else its Key. Null for fixed
    /// text (neither set), which is never overwritten.
    private static string? ReadKey(LayerSourceItemDto source) =>
        !string.IsNullOrWhiteSpace(source.SourceKey) ? source.SourceKey.Trim()
        : !string.IsNullOrWhiteSpace(source.Key) ? source.Key.Trim()
        : null;

    /// Fills each layer source's Value from the member's PDF. A source reads the PDF field
    /// named by its ReadKey; if the member's PDF does not have that field the value is
    /// cleared, never left as the template's sample text (that would print someone else's
    /// details on the card). Fixed text (no key) is left as designed. Image sources with no
    /// matching key take the remaining images in extraction order.
    private static void MergeExtractedValues(List<TemplateLayerDto> layers, List<ExtractedFieldDto> extractedFields)
    {
        var textFieldsByKey = extractedFields
            .Where(f => f.Type == LayerFieldType.Text && !string.IsNullOrEmpty(f.Key))
            .GroupBy(f => f.Key!.Trim(), StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.First().Value, StringComparer.OrdinalIgnoreCase);

        // QR slots are filled by key from the images the user picked in the card
        // generator, so those images must not be handed out as the member's PDF images.
        var qrKeys = layers.SelectMany(l => l.Groups)
            .Where(g => g.IsQr)
            .SelectMany(g => g.Sources)
            .Where(s => !string.IsNullOrWhiteSpace(s.Key))
            .Select(s => s.Key!.Trim())
            .ToHashSet(StringComparer.OrdinalIgnoreCase);
        var allImages = extractedFields.Where(f => f.Type == LayerFieldType.Image).ToList();
        var qrImagesByKey = allImages
            .Where(f => !string.IsNullOrWhiteSpace(f.Key) && qrKeys.Contains(f.Key!.Trim()))
            .GroupBy(f => f.Key!.Trim(), StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.First().Value, StringComparer.OrdinalIgnoreCase);
        var memberImages = allImages
            .Where(f => string.IsNullOrWhiteSpace(f.Key) || !qrKeys.Contains(f.Key!.Trim()))
            .ToList();

        // Image layers are matched by key first. A layer imported from the sample PDF keeps
        // that image's key (e.g. "image_p1_4"), so it gets the same image from the member's
        // PDF - not whichever image happens to come first (often a black mask). Layers with
        // no matching key take the remaining images in extraction order.
        var imageSourceKeys = layers.SelectMany(l => l.Groups)
            .Where(g => !g.IsQr)
            .SelectMany(g => g.Sources)
            .Where(s => s.Type == LayerFieldType.Image && ReadKey(s) != null)
            .Select(s => ReadKey(s)!)
            .ToHashSet(StringComparer.OrdinalIgnoreCase);
        var imagesByKey = memberImages
            .Where(f => !string.IsNullOrWhiteSpace(f.Key) && imageSourceKeys.Contains(f.Key!.Trim()))
            .GroupBy(f => f.Key!.Trim(), StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.First().Value, StringComparer.OrdinalIgnoreCase);
        var imageFields = memberImages
            .Where(f => string.IsNullOrWhiteSpace(f.Key) || !imagesByKey.ContainsKey(f.Key!.Trim()))
            .ToList();
        var imageIndex = 0;

        foreach (var group in layers.SelectMany(l => l.Groups))
        {
            if (group.IsQr)
            {
                foreach (var source in group.Sources)
                {
                    if (source.Type == LayerFieldType.Image && !string.IsNullOrWhiteSpace(source.Key)
                        && qrImagesByKey.TryGetValue(source.Key.Trim(), out var qrValue))
                    {
                        source.Value = qrValue;
                    }
                }
                continue;
            }

            foreach (var source in group.Sources)
            {
                if (source.Type == LayerFieldType.Text)
                {
                    var readKey = ReadKey(source);
                    if (readKey is not null)
                    {
                        source.Value = textFieldsByKey.TryGetValue(readKey, out var value) ? value ?? "" : "";
                    }
                }
                else if (source.Type == LayerFieldType.Image)
                {
                    var readKey = ReadKey(source);
                    if (readKey is not null && imagesByKey.TryGetValue(readKey, out var byKey))
                    {
                        source.Value = byKey;
                    }
                    else if (imageIndex < imageFields.Count)
                    {
                        source.Value = imageFields[imageIndex].Value;
                        imageIndex++;
                    }
                    else
                    {
                        source.Value = null; // not in the member's PDF: never keep the sample photo
                    }
                }
            }
        }
    }

    private static TemplateSummaryDto ToSummaryDto(CardTemplateEntity t) => new()
    {
        Id = t.Id,
        Name = t.Name,
        CardWidthMm = t.CardWidthMm,
        CardHeightMm = t.CardHeightMm,
        PointCost = t.PointCost,
        IsActive = t.IsActive,
        FrontImageBase64 = Convert.ToBase64String(t.FrontImage),
        BackImageBase64 = Convert.ToBase64String(t.BackImage),
        FileNamePattern = t.FileNamePattern,
        CreatedAt = t.CreatedAt,
    };

    private static TemplateDetailDto ToDetailDto(CardTemplateEntity t)
    {
        var summary = ToSummaryDto(t);
        return new TemplateDetailDto
        {
            Id = summary.Id,
            Name = summary.Name,
            CardWidthMm = summary.CardWidthMm,
            CardHeightMm = summary.CardHeightMm,
            PointCost = summary.PointCost,
            IsActive = summary.IsActive,
            FrontImageBase64 = summary.FrontImageBase64,
            BackImageBase64 = summary.BackImageBase64,
            CreatedAt = summary.CreatedAt,
            FileNamePattern = summary.FileNamePattern,
            Groups = JsonSerializer.Deserialize<List<FieldGroupDto>>(t.GroupsJson, JsonOptions) ?? [],
            Layers = t.LayersJson != null
                ? JsonSerializer.Deserialize<List<TemplateLayerDto>>(t.LayersJson, JsonOptions) ?? []
                : [],
            Combinations = t.Combinations.Select(ToCombinationDto).ToList(),
        };
    }

    private static CombinationDto ToCombinationDto(TemplateCombinationEntity c) => new()
    {
        Id = c.Id,
        Name = c.Name,
        FrontImageBase64 = Convert.ToBase64String(c.FrontImage),
        BackImageBase64 = Convert.ToBase64String(c.BackImage),
    };
}
