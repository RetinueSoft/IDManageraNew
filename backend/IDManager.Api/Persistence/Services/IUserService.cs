using IDManager.Api.Dtos;

namespace IDManager.Api.Persistence.Services;

public interface IUserService
{
    Task<PagedResult<UserDto>> GetAllAsync(int requestedById, PagedRequest request);
    Task<UserDto> GetByIdAsync(int id);
    Task<UserDto> CreateAsync(int createdById, CreateUserRequest request);
    Task<UserDto> UpdateAsync(UpdateUserRequest request);
    Task DeactivateAsync(int id);
}
