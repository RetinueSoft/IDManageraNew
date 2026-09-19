using IDManager.Api.Security;
using IDManager.Domain.Dtos;
using IDManager.Infrastructure.AuditLog;
using IDManager.Infrastructure.Users;

namespace IDManager.Api.Endpoints;

public static class UserEndpoints
{
    private static readonly string[] ManagerRoles = ["SuperAdmin", "Admin", "Distributor"];

    public static void MapUserEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/users").RequireAuthorization();

        group.MapPost("/list", async (PagedRequest request, UserService service, HttpContext http, CancellationToken ct) =>
            Results.Ok(await service.GetAllAsync(http.User.GetUserId(), request, ct)));

        group.MapGet("/{id:int}", async (int id, UserService service, CancellationToken ct) =>
            (await service.GetByIdAsync(id, ct)).ToHttpResult());

        group.MapPost("/", async (CreateUserRequest request, UserService service, AuditLogService auditLog, HttpContext http, CancellationToken ct) =>
        {
            var result = await service.CreateAsync(http.User.GetUserId(), request, ct);
            if (result.Value != null)
            {
                await auditLog.LogAsync(http.User.GetUserId(), "Create", "User", result.Value.Id.ToString(), null, ct);
            }
            return result.ToHttpResult();
        }).RequireAuthorization(p => p.RequireRole(ManagerRoles));

        group.MapPut("/", async (UpdateUserRequest request, UserService service, AuditLogService auditLog, HttpContext http, CancellationToken ct) =>
        {
            var result = await service.UpdateAsync(request, ct);
            if (result.Value != null)
            {
                await auditLog.LogAsync(http.User.GetUserId(), "Update", "User", result.Value.Id.ToString(), null, ct);
            }
            return result.ToHttpResult();
        }).RequireAuthorization(p => p.RequireRole(ManagerRoles));

        group.MapPost("/{id:int}/deactivate", async (int id, UserService service, AuditLogService auditLog, HttpContext http, CancellationToken ct) =>
        {
            var result = await service.DeactivateAsync(id, ct);
            await auditLog.LogAsync(http.User.GetUserId(), "Deactivate", "User", id.ToString(), null, ct);
            return result.ToHttpResult();
        }).RequireAuthorization(p => p.RequireRole(ManagerRoles));
    }
}
