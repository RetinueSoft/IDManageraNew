using System.Text.Json;
using IDManager.Api.Domain.Entities;
using IDManager.Api.Dtos;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Api.Persistence.Services;

public class AuditLogService : IAuditLogService
{
    private readonly ApplicationDbContext _db;

    public AuditLogService(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task LogAsync(int? userId, string action, string entityName, string? entityId, object? details = null)
    {
        _db.AuditLogs.Add(new AuditLog
        {
            UserId = userId,
            Action = action,
            EntityName = entityName,
            EntityId = entityId,
            DetailsJson = details != null ? JsonSerializer.Serialize(details) : null
        });
        await _db.SaveChangesAsync();
    }

    public async Task<PagedResult<AuditLog>> GetAllAsync(PagedRequest request)
    {
        var query = _db.AuditLogs.OrderByDescending(a => a.CreatedAt);
        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((request.PageIndex - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync();

        return new PagedResult<AuditLog>
        {
            Items = items,
            TotalCount = totalCount,
            PageIndex = request.PageIndex,
            PageSize = request.PageSize
        };
    }
}
