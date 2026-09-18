using IDManager.Api.Dtos;

namespace IDManager.Api.Persistence.Services;

public interface ITemplateService
{
    Task<PagedResult<TemplateSummaryDto>> GetAllAsync(PagedRequest request);
    Task<TemplateDetailDto> GetTemplateAsync(int id);
    Task<TemplateDetailDto> CreateAsync(int createdById, CreateTemplateRequest request);
    Task<TemplateDetailDto> UpdateAsync(UpdateTemplateRequest request);
    Task SetActiveAsync(int id, bool active);
    Task SaveLayersAsync(SaveLayersRequest request);
    Task<CombinationDto> AddCombinationAsync(AddCombinationRequest request);
    Task DeleteCombinationAsync(int combinationId);

    // Matches a member's extracted PDF fields against the template's positioned layers
    // by key, filling each layer source's value so the result can be rendered/printed
    // directly at its designed position - no groups round-trip needed.
    Task<(List<TemplateLayerDto> Layers, byte[] FrontImage, byte[] BackImage)> MatchToTemplateAsync(
        int templateId, int combinationId, List<ExtractedFieldDto> extractedFields);
}
