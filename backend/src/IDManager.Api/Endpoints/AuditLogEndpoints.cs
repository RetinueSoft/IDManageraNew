using IDManager.Domain.Dtos;
using IDManager.Infrastructure.AuditLog;

namespace IDManager.Api.Endpoints;

public static class AuditLogEndpoints
{
    public static void MapAuditLogEndpoints(this WebApplication app)
    {
        app.MapPost("/api/audit-log/list", async (PagedRequest request, AuditLogService service, CancellationToken ct) =>
            Results.Ok(await service.GetAllAsync(request, ct)))
            .RequireAuthorization(p => p.RequireRole("SuperAdmin"));
    }
}
