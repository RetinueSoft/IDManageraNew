using IDManager.Api.Domain.Entities;
using IDManager.Api.Dtos;

namespace IDManager.Api.Persistence.Services;

public interface IUserPointService
{
    Task<int> GetUserPointsAsync(int userId);
    Task<int> AdjustPointsAsync(int requestedById, AdjustPointsRequest request, bool increase);
    Task<PagedResult<PointTransactionDto>> GetAllAsync(int userId, bool includeIncompleteAlso, PagedRequest request);
    Task<int> CreateIdCardAsync(IDCard idCard, string forName);
    Task CompletePaymentTransactionAsync(int idCardId);
}
