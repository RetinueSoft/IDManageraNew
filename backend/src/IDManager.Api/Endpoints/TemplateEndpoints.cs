using IDManager.Api.Security;
using IDManager.Domain.Dtos;
using IDManager.Infrastructure.AuditLog;
using IDManager.Infrastructure.Templates;

namespace IDManager.Api.Endpoints;

public static class TemplateEndpoints
{
    private static readonly string[] AdminRoles = ["SuperAdmin", "Admin"];

    public static void MapTemplateEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/templates").RequireAuthorization();

        group.MapPost("/list", async (PagedRequest request, TemplateService service, CancellationToken ct) =>
            Results.Ok(await service.GetAllAsync(request, ct)));

        group.MapGet("/{id:int}", async (int id, TemplateService service, CancellationToken ct) =>
            (await service.GetTemplateAsync(id, ct)).ToHttpResult());

        group.MapPost("/", async (HttpRequest request, TemplateService service, AuditLogService auditLog, CancellationToken ct) =>
        {
            var form = await request.ReadFormAsync(ct);
            var command = new CreateTemplateCommand
            {
                Name = form["name"].ToString(),
                CardWidthMm = double.TryParse(form["cardWidthMm"], out var w) ? w : 85.6,
                CardHeightMm = double.TryParse(form["cardHeightMm"], out var h) ? h : 54.0,
                PointCost = int.TryParse(form["pointCost"], out var p) ? p : 1,
                GroupsJson = form["groupsJson"].ToString() is { Length: > 0 } g ? g : "[]",
                FrontImageBytes = await ReadFileBytesAsync(form.Files.GetFile("frontFile"), ct),
                BackImageBytes = await ReadFileBytesAsync(form.Files.GetFile("backFile"), ct),
            };

            var result = await service.CreateAsync(request.HttpContext.User.GetUserId(), command, ct);
            if (result.Value != null)
            {
                await auditLog.LogAsync(request.HttpContext.User.GetUserId(), "Create", "Template", result.Value.Id.ToString(), null, ct);
            }
            return result.ToHttpResult();
        }).RequireAuthorization(policy => policy.RequireRole(AdminRoles)).DisableAntiforgery();

        group.MapPut("/{id:int}", async (int id, HttpRequest request, TemplateService service, AuditLogService auditLog, CancellationToken ct) =>
        {
            var form = await request.ReadFormAsync(ct);
            var command = new UpdateTemplateCommand
            {
                Id = id,
                Name = form["name"].ToString(),
                PointCost = int.TryParse(form["pointCost"], out var p) ? p : 0,
                IsActive = bool.TryParse(form["isActive"], out var active) && active,
                GroupsJson = form["groupsJson"].ToString() is { Length: > 0 } g ? g : "[]",
                FrontImageBytes = form.Files.GetFile("frontFile") is { } front ? await ReadFileBytesAsync(front, ct) : null,
                BackImageBytes = form.Files.GetFile("backFile") is { } back ? await ReadFileBytesAsync(back, ct) : null,
            };

            var result = await service.UpdateAsync(command, ct);
            if (result.Value != null)
            {
                await auditLog.LogAsync(request.HttpContext.User.GetUserId(), "Update", "Template", id.ToString(), null, ct);
            }
            return result.ToHttpResult();
        }).RequireAuthorization(policy => policy.RequireRole(AdminRoles)).DisableAntiforgery();

        group.MapPost("/{id:int}/activate", async (int id, TemplateService service, CancellationToken ct) =>
            (await service.SetActiveAsync(id, true, ct)).ToHttpResult())
            .RequireAuthorization(policy => policy.RequireRole(AdminRoles));

        group.MapPost("/{id:int}/deactivate", async (int id, TemplateService service, CancellationToken ct) =>
            (await service.SetActiveAsync(id, false, ct)).ToHttpResult())
            .RequireAuthorization(policy => policy.RequireRole(AdminRoles));

        group.MapPost("/layers", async (SaveLayersRequest request, TemplateService service, AuditLogService auditLog, HttpContext http, CancellationToken ct) =>
        {
            var result = await service.SaveLayersAsync(request, ct);
            await auditLog.LogAsync(http.User.GetUserId(), "SaveLayers", "Template", request.TemplateId.ToString(), null, ct);
            return result.ToHttpResult();
        }).RequireAuthorization(policy => policy.RequireRole(AdminRoles));

        group.MapPost("/combinations", async (HttpRequest request, TemplateService service, CancellationToken ct) =>
        {
            var form = await request.ReadFormAsync(ct);
            var command = new AddCombinationCommand
            {
                TemplateId = int.TryParse(form["templateId"], out var id) ? id : 0,
                Name = form["name"].ToString(),
                FrontImageBytes = await ReadFileBytesAsync(form.Files.GetFile("frontFile"), ct),
                BackImageBytes = await ReadFileBytesAsync(form.Files.GetFile("backFile"), ct),
            };
            return (await service.AddCombinationAsync(command, ct)).ToHttpResult();
        }).RequireAuthorization(policy => policy.RequireRole(AdminRoles)).DisableAntiforgery();

        group.MapDelete("/combinations/{combinationId:int}", async (int combinationId, TemplateService service, CancellationToken ct) =>
            (await service.DeleteCombinationAsync(combinationId, ct)).ToHttpResult())
            .RequireAuthorization(policy => policy.RequireRole(AdminRoles));
    }

    private static async Task<byte[]> ReadFileBytesAsync(IFormFile? file, CancellationToken ct)
    {
        if (file is null) return [];
        using var ms = new MemoryStream();
        await file.CopyToAsync(ms, ct);
        return ms.ToArray();
    }
}
