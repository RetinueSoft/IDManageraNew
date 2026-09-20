using IDManager.Api.Security;
using IDManager.Domain.Dtos;
using IDManager.Infrastructure.AuditLog;
using IDManager.Infrastructure.Points;

namespace IDManager.Api.Endpoints;

public static class PointsEndpoints
{
    // Roles that can allocate/reclaim points (docs/member-hierarchy.md). Which members a
    // caller may touch is decided by the service, not by the role alone.
    private static readonly string[] ManagerRoles = ["SuperAdmin", "Distributor", "Retailer"];

    public static void MapPointsEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/points").RequireAuthorization();

        group.MapGet("/balance", async (PointsService service, HttpContext http, CancellationToken ct) =>
            Results.Ok(await service.GetUserPointsAsync(http.User.GetUserId(), ct)));

        group.MapPost("/list", async (GetPointsRequest request, PointsService service, HttpContext http, CancellationToken ct) =>
            (await service.GetAllAsync(http.User.GetUserId(), request, ct)).ToHttpResult());

        group.MapPost("/increase", async (AdjustPointsRequest request, PointsService service, AuditLogService auditLog, HttpContext http, CancellationToken ct) =>
        {
            var result = await service.AdjustPointsAsync(http.User.GetUserId(), request, increase: true, ct);
            await auditLog.LogAsync(http.User.GetUserId(), "IncreasePoints", "User", request.UserId.ToString(), new { request.Points }, ct);
            return result.ToHttpResult();
        }).RequireAuthorization(p => p.RequireRole(ManagerRoles));

        group.MapPost("/decrease", async (AdjustPointsRequest request, PointsService service, AuditLogService auditLog, HttpContext http, CancellationToken ct) =>
        {
            var result = await service.AdjustPointsAsync(http.User.GetUserId(), request, increase: false, ct);
            await auditLog.LogAsync(http.User.GetUserId(), "DecreasePoints", "User", request.UserId.ToString(), new { request.Points }, ct);
            return result.ToHttpResult();
        }).RequireAuthorization(p => p.RequireRole("SuperAdmin")); // only a Super Admin reclaims points
    }
}
