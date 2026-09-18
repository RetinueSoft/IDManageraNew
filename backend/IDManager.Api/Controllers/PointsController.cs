using IDManager.Api.Dtos;
using IDManager.Api.Persistence.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IDManager.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PointsController : ApiControllerBase
{
    private readonly IUserPointService _pointService;
    private readonly IAuditLogService _auditLog;

    public PointsController(IUserPointService pointService, IAuditLogService auditLog)
    {
        _pointService = pointService;
        _auditLog = auditLog;
    }

    [HttpGet("Balance")]
    public async Task<ActionResult<ApiResponse<int>>> Balance()
    {
        var points = await _pointService.GetUserPointsAsync(CurrentUserId);
        return Ok(ApiResponse<int>.Ok(points));
    }

    [HttpPost("GetAll")]
    public async Task<ActionResult<ApiResponse<PagedResult<PointTransactionDto>>>> GetAll([FromBody] GetPointsRequest request)
    {
        var result = await _pointService.GetAllAsync(request.UserId, request.IncludeIncompleteAlso, request);
        return Ok(ApiResponse<PagedResult<PointTransactionDto>>.Ok(result));
    }

    [Authorize(Roles = "SuperAdmin,Admin,Distributor")]
    [HttpPost("Increase")]
    public async Task<ActionResult<ApiResponse<int>>> Increase([FromBody] AdjustPointsRequest request)
    {
        var newBalance = await _pointService.AdjustPointsAsync(CurrentUserId, request, increase: true);
        await _auditLog.LogAsync(CurrentUserId, "IncreasePoints", "User", request.UserId.ToString(), new { request.Points });
        return Ok(ApiResponse<int>.Ok(newBalance));
    }

    [Authorize(Roles = "SuperAdmin,Admin,Distributor")]
    [HttpPost("Decrease")]
    public async Task<ActionResult<ApiResponse<int>>> Decrease([FromBody] AdjustPointsRequest request)
    {
        var newBalance = await _pointService.AdjustPointsAsync(CurrentUserId, request, increase: false);
        await _auditLog.LogAsync(CurrentUserId, "DecreasePoints", "User", request.UserId.ToString(), new { request.Points });
        return Ok(ApiResponse<int>.Ok(newBalance));
    }

    public class GetPointsRequest : PagedRequest
    {
        public int UserId { get; set; }
        public bool IncludeIncompleteAlso { get; set; }
    }
}
