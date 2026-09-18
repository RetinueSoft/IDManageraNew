using System.Security.Claims;
using IDManager.Api.Domain.Enums;
using Microsoft.AspNetCore.Mvc;

namespace IDManager.Api.Controllers;

public abstract class ApiControllerBase : ControllerBase
{
    protected int CurrentUserId
    {
        get
        {
            var claim = User.FindFirst("UserId");
            return claim != null ? int.Parse(claim.Value) : 0;
        }
    }

    protected UserRole CurrentRole
    {
        get
        {
            var claim = User.FindFirst(ClaimTypes.Role);
            return claim != null && Enum.TryParse<UserRole>(claim.Value, out var role) ? role : UserRole.Unknown;
        }
    }
}
