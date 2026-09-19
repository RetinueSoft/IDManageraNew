using System.Text.Json;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure.AuditLog;

public class AuditLogService(IDManagerDbContext db)
{
    public async Task LogAsync(int? userId, string action, string entityName, string? entityId, object? details, CancellationToken ct)
    {
        db.AuditLogs.Add(new AuditLogEntity
        {
            UserId = userId,
            Action = action,
            EntityName = entityName,
            EntityId = entityId,
            DetailsJson = details != null ? JsonSerializer.Serialize(details) : null,
        });
        await db.SaveChangesAsync(ct);
    }

    public async Task<PagedResult<AuditLogEntity>> GetAllAsync(PagedRequest request, CancellationToken ct)
    {
        var query = db.AuditLogs.OrderByDescending(a => a.CreatedAt);
        var totalCount = await query.CountAsync(ct);
        var items = await query
            .Skip((request.PageIndex - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(ct);

        return new PagedResult<AuditLogEntity>
        {
            Items = items,
            TotalCount = totalCount,
            PageIndex = request.PageIndex,
            PageSize = request.PageSize,
        };
    }
}
