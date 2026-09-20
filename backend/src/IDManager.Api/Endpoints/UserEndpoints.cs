using IDManager.Api.Security;
using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Infrastructure.AuditLog;
using IDManager.Infrastructure.Users;

namespace IDManager.Api.Endpoints;

public static class UserEndpoints
{
    // Roles that have the member screens (docs/member-hierarchy.md). Which members a
    // caller may touch is decided by the service, not by the role alone.
    private static readonly string[] ManagerRoles = ["SuperAdmin", "Distributor", "Retailer"];

    public static void MapUserEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/users").RequireAuthorization();

        group.MapPost("/list", async (PagedRequest request, UserService service, HttpContext http, CancellationToken ct) =>
            Results.Ok(await service.GetAllAsync(http.User.GetUserId(), request, ct)));

        group.MapGet("/{id:int}", async (int id, UserService service, HttpContext http, CancellationToken ct) =>
            (await service.GetByIdAsync(http.User.GetUserId(), id, ct)).ToHttpResult());

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
            var result = await service.UpdateAsync(http.User.GetUserId(), request, ct);
            if (result.Value != null)
            {
                await auditLog.LogAsync(http.User.GetUserId(), "Update", "User", result.Value.Id.ToString(), null, ct);
            }
            return result.ToHttpResult();
        }).RequireAuthorization(p => p.RequireRole(ManagerRoles));

        // A member's identity card images (front / back). Viewing follows who can see the member
        // (docs/member-hierarchy.md, section 3); adding, replacing and removing follow who can edit
        // them. The images are never part of a member list.
        group.MapGet("/{id:int}/identity/{side}", async (int id, string side, UserService service, HttpContext http, CancellationToken ct) =>
        {
            if (!TryParseSide(side, out var identitySide)) return Results.NotFound(new { error = "Unknown side." });
            var result = await service.GetIdentityImageAsync(http.User.GetUserId(), id, identitySide, ct);
            return result.Status == ResultStatus.Success
                ? Results.File(result.Value!.Bytes, result.Value.ContentType)
                : result.ToHttpResult();
        });

        group.MapPut("/{id:int}/identity/{side}", async (int id, string side, HttpRequest request, UserService service, AuditLogService auditLog, HttpContext http, CancellationToken ct) =>
        {
            if (!TryParseSide(side, out var identitySide)) return Results.NotFound(new { error = "Unknown side." });
            var form = await request.ReadFormAsync(ct);
            var file = form.Files.GetFile("file");
            if (file is null) return Results.BadRequest(new { error = "No file uploaded." });

            using var ms = new MemoryStream();
            await file.CopyToAsync(ms, ct);
            var result = await service.SetIdentityImageAsync(http.User.GetUserId(), id, identitySide, ms.ToArray(), ct);
            if (result.Status == ResultStatus.Success)
            {
                await auditLog.LogAsync(http.User.GetUserId(), "SetIdentityImage", "User", id.ToString(), identitySide.ToString(), ct);
            }
            return result.ToHttpResult();
        }).RequireAuthorization(p => p.RequireRole(ManagerRoles)).DisableAntiforgery();

        group.MapDelete("/{id:int}/identity/{side}", async (int id, string side, UserService service, AuditLogService auditLog, HttpContext http, CancellationToken ct) =>
        {
            if (!TryParseSide(side, out var identitySide)) return Results.NotFound(new { error = "Unknown side." });
            var result = await service.DeleteIdentityImageAsync(http.User.GetUserId(), id, identitySide, ct);
            if (result.Status == ResultStatus.Success)
            {
                await auditLog.LogAsync(http.User.GetUserId(), "RemoveIdentityImage", "User", id.ToString(), identitySide.ToString(), ct);
            }
            return result.ToHttpResult();
        }).RequireAuthorization(p => p.RequireRole(ManagerRoles));

        group.MapPost("/{id:int}/deactivate", async (int id, UserService service, AuditLogService auditLog, HttpContext http, CancellationToken ct) =>
        {
            var result = await service.DeactivateAsync(http.User.GetUserId(), id, ct);
            await auditLog.LogAsync(http.User.GetUserId(), "Deactivate", "User", id.ToString(), null, ct);
            return result.ToHttpResult();
        }).RequireAuthorization(p => p.RequireRole("SuperAdmin")); // only a Super Admin activates/deactivates
    }

    private static bool TryParseSide(string side, out IdentitySide result)
    {
        switch (side.ToLowerInvariant())
        {
            case "front": result = IdentitySide.Front; return true;
            case "back": result = IdentitySide.Back; return true;
            default: result = default; return false;
        }
    }
}
