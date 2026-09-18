using IDManager.Api.Dtos;
using IDManager.Api.Utils;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Api.Persistence.Services;

public class AuthService : IAuthService
{
    private readonly ApplicationDbContext _db;
    private readonly JwtTokenGenerator _tokenGenerator;

    public AuthService(ApplicationDbContext db, JwtTokenGenerator tokenGenerator)
    {
        _db = db;
        _tokenGenerator = tokenGenerator;
    }

    public async Task<LoginResponse> LoginAsync(LoginRequest request)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Phone == request.Phone);
        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid phone number or password.");

        if (!user.Status)
            throw new UnauthorizedAccessException("This account has been deactivated.");

        var token = _tokenGenerator.GenerateToken(user);

        return new LoginResponse
        {
            AccessToken = token,
            User = new UserDto
            {
                Id = user.Id,
                Name = user.Name,
                Phone = user.Phone,
                Role = user.Role,
                Status = user.Status,
                Points = user.Points,
                CreatedAt = user.CreatedAt
            }
        };
    }
}
