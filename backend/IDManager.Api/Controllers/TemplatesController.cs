using IDManager.Api.Dtos;
using IDManager.Api.Persistence.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IDManager.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TemplatesController : ApiControllerBase
{
    private readonly ITemplateService _templateService;
    private readonly IAuditLogService _auditLog;

    public TemplatesController(ITemplateService templateService, IAuditLogService auditLog)
    {
        _templateService = templateService;
        _auditLog = auditLog;
    }

    [HttpPost("GetAll")]
    public async Task<IActionResult> GetAll([FromBody] PagedRequest request)
    {
        var result = await _templateService.GetAllAsync(request);
        return Ok(ApiResponse<PagedResult<TemplateSummaryDto>>.Ok(result));
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetTemplate(int id)
    {
        var result = await _templateService.GetTemplateAsync(id);
        return Ok(ApiResponse<TemplateDetailDto>.Ok(result));
    }

    [Authorize(Roles = "SuperAdmin,Admin")]
    [Consumes("multipart/form-data")]
    [HttpPost("Create")]
    public async Task<IActionResult> Create([FromForm] CreateTemplateRequest request)
    {
        var result = await _templateService.CreateAsync(CurrentUserId, request);
        await _auditLog.LogAsync(CurrentUserId, "Create", nameof(TemplateDetailDto), result.Id.ToString());
        return Ok(ApiResponse<TemplateDetailDto>.Ok(result));
    }

    [Authorize(Roles = "SuperAdmin,Admin")]
    [Consumes("multipart/form-data")]
    [HttpPost("Update")]
    public async Task<IActionResult> Update([FromForm] UpdateTemplateRequest request)
    {
        var result = await _templateService.UpdateAsync(request);
        await _auditLog.LogAsync(CurrentUserId, "Update", nameof(TemplateDetailDto), result.Id.ToString());
        return Ok(ApiResponse<TemplateDetailDto>.Ok(result));
    }

    [Authorize(Roles = "SuperAdmin,Admin")]
    [HttpPost("Activate")]
    public async Task<IActionResult> Activate([FromBody] int templateId)
    {
        await _templateService.SetActiveAsync(templateId, true);
        return Ok(ApiResponse.Ok());
    }

    [Authorize(Roles = "SuperAdmin,Admin")]
    [HttpPost("Deactivate")]
    public async Task<IActionResult> Deactivate([FromBody] int templateId)
    {
        await _templateService.SetActiveAsync(templateId, false);
        return Ok(ApiResponse.Ok());
    }

    [Authorize(Roles = "SuperAdmin,Admin")]
    [HttpPost("SaveLayers")]
    public async Task<IActionResult> SaveLayers([FromBody] SaveLayersRequest request)
    {
        await _templateService.SaveLayersAsync(request);
        await _auditLog.LogAsync(CurrentUserId, "SaveLayers", nameof(TemplateDetailDto), request.TemplateId.ToString());
        return Ok(ApiResponse.Ok());
    }

    [Authorize(Roles = "SuperAdmin,Admin")]
    [Consumes("multipart/form-data")]
    [HttpPost("AddCombination")]
    public async Task<IActionResult> AddCombination([FromForm] AddCombinationRequest request)
    {
        var result = await _templateService.AddCombinationAsync(request);
        return Ok(ApiResponse<CombinationDto>.Ok(result));
    }

    [Authorize(Roles = "SuperAdmin,Admin")]
    [HttpPost("DeleteCombination")]
    public async Task<IActionResult> DeleteCombination([FromBody] int combinationId)
    {
        await _templateService.DeleteCombinationAsync(combinationId);
        return Ok(ApiResponse.Ok());
    }
}
