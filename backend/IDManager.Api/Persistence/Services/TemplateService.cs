using System.Text.Json;
using IDManager.Api.Domain.Entities;
using IDManager.Api.Dtos;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Api.Persistence.Services;

public class TemplateService : ITemplateService
{
    private readonly ApplicationDbContext _db;
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };

    public TemplateService(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<PagedResult<TemplateSummaryDto>> GetAllAsync(PagedRequest request)
    {
        var query = _db.CardTemplates.AsQueryable();
        if (!string.IsNullOrWhiteSpace(request.SearchBy))
            query = query.Where(t => t.Name.Contains(request.SearchBy));

        var totalCount = await query.CountAsync();
        var items = await query
            .OrderByDescending(t => t.CreatedAt)
            .Skip((request.PageIndex - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync();

        return new PagedResult<TemplateSummaryDto>
        {
            Items = items.Select(ToSummaryDto).ToList(),
            TotalCount = totalCount,
            PageIndex = request.PageIndex,
            PageSize = request.PageSize
        };
    }

    public async Task<TemplateDetailDto> GetTemplateAsync(int id)
    {
        var template = await _db.CardTemplates
            .Include(t => t.Combinations)
            .FirstOrDefaultAsync(t => t.Id == id)
            ?? throw new ArgumentException("Template not found.");

        return ToDetailDto(template);
    }

    public async Task<TemplateDetailDto> CreateAsync(int createdById, CreateTemplateRequest request)
    {
        if (request.FrontFile == null || request.BackFile == null)
            throw new ArgumentException("Front and back images are required.");

        var template = new CardTemplate
        {
            Name = request.Name,
            CardWidthMm = request.CardWidthMm,
            CardHeightMm = request.CardHeightMm,
            PointCost = request.PointCost,
            GroupsJson = request.GroupsJson,
            Status = true,
            CreatedById = createdById,
            FrontImage = await ToBytesAsync(request.FrontFile),
            BackImage = await ToBytesAsync(request.BackFile)
        };

        _db.CardTemplates.Add(template);
        await _db.SaveChangesAsync();

        return ToDetailDto(template);
    }

    public async Task<TemplateDetailDto> UpdateAsync(UpdateTemplateRequest request)
    {
        var template = await _db.CardTemplates
            .Include(t => t.Combinations)
            .FirstOrDefaultAsync(t => t.Id == request.Id)
            ?? throw new ArgumentException("Template not found.");

        template.Name = request.Name;
        template.PointCost = request.PointCost;
        template.Status = request.Status;
        template.GroupsJson = request.GroupsJson;
        template.ModifiedAt = DateTime.UtcNow;

        if (request.FrontFile != null)
            template.FrontImage = await ToBytesAsync(request.FrontFile);
        if (request.BackFile != null)
            template.BackImage = await ToBytesAsync(request.BackFile);

        await _db.SaveChangesAsync();
        return ToDetailDto(template);
    }

    public async Task SetActiveAsync(int id, bool active)
    {
        var template = await _db.CardTemplates.FindAsync(id) ?? throw new ArgumentException("Template not found.");
        template.Status = active;
        template.ModifiedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
    }

    public async Task SaveLayersAsync(SaveLayersRequest request)
    {
        var template = await _db.CardTemplates.FindAsync(request.TemplateId)
            ?? throw new ArgumentException("Template not found.");

        template.LayersJson = JsonSerializer.Serialize(request.Layers);
        template.ModifiedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
    }

    public async Task<CombinationDto> AddCombinationAsync(AddCombinationRequest request)
    {
        var template = await _db.CardTemplates.FindAsync(request.TemplateId)
            ?? throw new ArgumentException("Template not found.");

        var combination = new TemplateCombination
        {
            TemplateId = template.Id,
            Name = request.Name,
            FrontImage = await ToBytesAsync(request.FrontFile),
            BackImage = await ToBytesAsync(request.BackFile)
        };

        _db.TemplateCombinations.Add(combination);
        await _db.SaveChangesAsync();

        return ToCombinationDto(combination);
    }

    public async Task DeleteCombinationAsync(int combinationId)
    {
        var combination = await _db.TemplateCombinations.FindAsync(combinationId)
            ?? throw new ArgumentException("Combination not found.");
        _db.TemplateCombinations.Remove(combination);
        await _db.SaveChangesAsync();
    }

    public async Task<(List<TemplateLayerDto> Layers, byte[] FrontImage, byte[] BackImage)> MatchToTemplateAsync(
        int templateId, int combinationId, List<ExtractedFieldDto> extractedFields)
    {
        var template = await _db.CardTemplates.FindAsync(templateId)
            ?? throw new ArgumentException("Template not found.");
        var combination = await _db.TemplateCombinations.FindAsync(combinationId)
            ?? throw new ArgumentException("Combination not found.");

        var layers = template.LayersJson != null
            ? JsonSerializer.Deserialize<List<TemplateLayerDto>>(template.LayersJson, JsonOptions) ?? new()
            : new();

        MergeExtractedValues(layers, extractedFields);

        return (layers, combination.FrontImage, combination.BackImage);
    }

    // Fills each layer source's Value from the matching extracted field: text sources
    // are matched by key (the field name captured while designing the layout), image
    // sources are assigned in extraction order since a scanned photo/QR has no key.
    private static void MergeExtractedValues(List<TemplateLayerDto> layers, List<ExtractedFieldDto> extractedFields)
    {
        var textFieldsByKey = extractedFields
            .Where(f => f.Type == Domain.Enums.LayerFieldType.Text && !string.IsNullOrEmpty(f.Key))
            .GroupBy(f => f.Key!.Trim(), StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.First().Value, StringComparer.OrdinalIgnoreCase);
        var imageFields = extractedFields.Where(f => f.Type == Domain.Enums.LayerFieldType.Image).ToList();
        var imageIndex = 0;

        foreach (var group in layers.SelectMany(l => l.Groups))
        {
            foreach (var source in group.Sources)
            {
                if (source.Type == Domain.Enums.LayerFieldType.Text && source.Key != null
                    && textFieldsByKey.TryGetValue(source.Key.Trim(), out var value))
                {
                    source.Value = value;
                }
                else if (source.Type == Domain.Enums.LayerFieldType.Image && imageIndex < imageFields.Count)
                {
                    source.Value = imageFields[imageIndex].Value;
                    imageIndex++;
                }
            }
        }
    }

    private static async Task<byte[]> ToBytesAsync(IFormFile file)
    {
        using var ms = new MemoryStream();
        await file.CopyToAsync(ms);
        return ms.ToArray();
    }

    private static TemplateSummaryDto ToSummaryDto(CardTemplate t) => new()
    {
        Id = t.Id,
        Name = t.Name,
        CardWidthMm = t.CardWidthMm,
        CardHeightMm = t.CardHeightMm,
        PointCost = t.PointCost,
        Status = t.Status,
        FrontImageBase64 = Convert.ToBase64String(t.FrontImage),
        BackImageBase64 = Convert.ToBase64String(t.BackImage),
        CreatedAt = t.CreatedAt
    };

    private static TemplateDetailDto ToDetailDto(CardTemplate t)
    {
        var summary = ToSummaryDto(t);
        return new TemplateDetailDto
        {
            Id = summary.Id,
            Name = summary.Name,
            CardWidthMm = summary.CardWidthMm,
            CardHeightMm = summary.CardHeightMm,
            PointCost = summary.PointCost,
            Status = summary.Status,
            FrontImageBase64 = summary.FrontImageBase64,
            BackImageBase64 = summary.BackImageBase64,
            CreatedAt = summary.CreatedAt,
            Groups = JsonSerializer.Deserialize<List<FieldGroupDto>>(t.GroupsJson, JsonOptions) ?? new(),
            Layers = t.LayersJson != null
                ? JsonSerializer.Deserialize<List<TemplateLayerDto>>(t.LayersJson, JsonOptions) ?? new()
                : new(),
            Combinations = t.Combinations.Select(ToCombinationDto).ToList()
        };
    }

    private static CombinationDto ToCombinationDto(TemplateCombination c) => new()
    {
        Id = c.Id,
        Name = c.Name,
        FrontImageBase64 = Convert.ToBase64String(c.FrontImage),
        BackImageBase64 = Convert.ToBase64String(c.BackImage)
    };
}
