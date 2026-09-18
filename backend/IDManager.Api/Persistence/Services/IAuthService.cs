using IDManager.Api.Dtos;

namespace IDManager.Api.Persistence.Services;

public interface IAuthService
{
    Task<LoginResponse> LoginAsync(LoginRequest request);
}
