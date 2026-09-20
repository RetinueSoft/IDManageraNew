using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using IDManager.Domain.Entities;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace IDManager.Infrastructure.Security;

public class JwtTokenGenerator
{
    public const int DefaultExpiryMinutes = 30;

    private readonly string _key;
    private readonly int _expiryMinutes;

    public JwtTokenGenerator(IConfiguration configuration)
    {
        _key = configuration["Jwt:Key"]
            ?? throw new InvalidOperationException("Jwt:Key is not configured.");
        // A login lasts this long from the moment of login (30 minutes unless configured otherwise).
        _expiryMinutes = configuration.GetValue("Jwt:ExpiryMinutes", DefaultExpiryMinutes);
    }

    public string GenerateToken(UserEntity user)
    {
        var claims = new[]
        {
            new Claim("UserId", user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Name),
            new Claim(ClaimTypes.Role, user.Role.ToString()),
        };

        var credentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_key)),
            SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_expiryMinutes),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
