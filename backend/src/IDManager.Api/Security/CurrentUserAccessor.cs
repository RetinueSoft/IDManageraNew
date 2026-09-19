using System.Security.Claims;
using IDManager.Domain.Enums;

namespace IDManager.Api.Security;

public static class CurrentUserAccessor
{
    public static int GetUserId(this ClaimsPrincipal user)
    {
        var claim = user.FindFirst("UserId");
        return claim != null ? int.Parse(claim.Value) : 0;
    }

    public static UserRole GetRole(this ClaimsPrincipal user)
    {
        var claim = user.FindFirst(ClaimTypes.Role);
        return claim != null && Enum.TryParse<UserRole>(claim.Value, out var role) ? role : UserRole.Unknown;
    }
}
