using IDManager.Api.Dtos;
using IDManager.Api.Persistence.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IDManager.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "SuperAdmin,Admin")]
public class AuditLogController : ApiControllerBase
{
    private readonly IAuditLogService _auditLogService;

    public AuditLogController(IAuditLogService auditLogService)
    {
        _auditLogService = auditLogService;
    }

    [HttpPost("GetAll")]
    public async Task<IActionResult> GetAll([FromBody] PagedRequest request)
    {
        var result = await _auditLogService.GetAllAsync(request);
        return Ok(ApiResponse<object>.Ok(result));
    }
}
