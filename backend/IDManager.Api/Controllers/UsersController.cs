using IDManager.Api.Dtos;
using IDManager.Api.Persistence.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IDManager.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UsersController : ApiControllerBase
{
    private readonly IUserService _userService;
    private readonly IAuditLogService _auditLog;

    public UsersController(IUserService userService, IAuditLogService auditLog)
    {
        _userService = userService;
        _auditLog = auditLog;
    }

    [HttpPost("GetAll")]
    public async Task<ActionResult<ApiResponse<PagedResult<UserDto>>>> GetAll([FromBody] PagedRequest request)
    {
        var result = await _userService.GetAllAsync(CurrentUserId, request);
        return Ok(ApiResponse<PagedResult<UserDto>>.Ok(result));
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ApiResponse<UserDto>>> GetById(int id)
    {
        var result = await _userService.GetByIdAsync(id);
        return Ok(ApiResponse<UserDto>.Ok(result));
    }

    [Authorize(Roles = "SuperAdmin,Admin,Distributor")]
    [HttpPost("Create")]
    public async Task<ActionResult<ApiResponse<UserDto>>> Create([FromBody] CreateUserRequest request)
    {
        var result = await _userService.CreateAsync(CurrentUserId, request);
        await _auditLog.LogAsync(CurrentUserId, "Create", nameof(UserDto), result.Id.ToString());
        return Ok(ApiResponse<UserDto>.Ok(result));
    }

    [Authorize(Roles = "SuperAdmin,Admin,Distributor")]
    [HttpPost("Update")]
    public async Task<ActionResult<ApiResponse<UserDto>>> Update([FromBody] UpdateUserRequest request)
    {
        var result = await _userService.UpdateAsync(request);
        await _auditLog.LogAsync(CurrentUserId, "Update", nameof(UserDto), result.Id.ToString());
        return Ok(ApiResponse<UserDto>.Ok(result));
    }

    [Authorize(Roles = "SuperAdmin,Admin,Distributor")]
    [HttpPost("Deactivate")]
    public async Task<ActionResult<ApiResponse>> Deactivate([FromBody] int userId)
    {
        await _userService.DeactivateAsync(userId);
        await _auditLog.LogAsync(CurrentUserId, "Deactivate", nameof(UserDto), userId.ToString());
        return Ok(ApiResponse.Ok());
    }
}
