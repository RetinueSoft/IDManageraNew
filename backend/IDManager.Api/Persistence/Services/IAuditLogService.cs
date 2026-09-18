using IDManager.Api.Domain.Entities;
using IDManager.Api.Dtos;

namespace IDManager.Api.Persistence.Services;

public interface IAuditLogService
{
    Task LogAsync(int? userId, string action, string entityName, string? entityId, object? details = null);
    Task<PagedResult<AuditLog>> GetAllAsync(PagedRequest request);
}
