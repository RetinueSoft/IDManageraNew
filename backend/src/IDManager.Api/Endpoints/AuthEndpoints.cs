using IDManager.Api.Security;
using IDManager.Domain.Dtos;
using IDManager.Infrastructure.Security;

namespace IDManager.Api.Endpoints;

public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this WebApplication app)
    {
        app.MapPost("/api/auth/login", async (LoginRequest request, AuthService service, CancellationToken ct) =>
        {
            var result = await service.LoginAsync(request, ct);
            return result.ToHttpResult();
        }).AllowAnonymous();
    }
}
