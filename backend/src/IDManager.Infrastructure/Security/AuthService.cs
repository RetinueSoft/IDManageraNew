using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure.Security;

public class AuthService(IDManagerDbContext db, JwtTokenGenerator tokenGenerator)
{
    public async Task<OperationResult<LoginResponse>> LoginAsync(LoginRequest request, CancellationToken ct)
    {
        var user = await db.Users.FirstOrDefaultAsync(u => u.Phone == request.Phone, ct);
        if (user is null || !PasswordHasher.Verify(request.Password, user.PasswordHash))
        {
            return OperationResult<LoginResponse>.Invalid("Invalid phone number or password.");
        }
        if (!user.IsActive)
        {
            return OperationResult<LoginResponse>.Forbidden("This account has been deactivated.");
        }

        var response = new LoginResponse
        {
            AccessToken = tokenGenerator.GenerateToken(user),
            User = new UserDto
            {
                Id = user.Id,
                Name = user.Name,
                Phone = user.Phone,
                Role = user.Role,
                IsActive = user.IsActive,
                Points = user.Points,
                CreatedAt = user.CreatedAt,
            },
        };
        return OperationResult<LoginResponse>.Success(response);
    }
}
