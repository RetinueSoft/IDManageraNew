using IDManager.Api.Security;
using IDManager.Infrastructure.Dashboard;

namespace IDManager.Api.Endpoints;

public static class DashboardEndpoints
{
    public static void MapDashboardEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/dashboard").RequireAuthorization();

        group.MapGet("/summary", async (DashboardService service, HttpContext http, CancellationToken ct) =>
            (await service.GetSummaryAsync(http.User.GetUserId(), ct)).ToHttpResult());
    }
}
