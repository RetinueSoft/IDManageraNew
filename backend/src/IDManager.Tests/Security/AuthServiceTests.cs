using IDManager.Domain.Common;
using IDManager.Domain.Dtos;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Security;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace IDManager.Tests.Security;

public class AuthServiceTests
{
    private static JwtTokenGenerator NewTokenGenerator()
    {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Jwt:Key"] = "test-signing-key-at-least-32-characters-long",
                ["Jwt:ExpiryMinutes"] = "60",
            })
            .Build();
        return new JwtTokenGenerator(config);
    }

    [Fact]
    public async Task LoginAsync_ValidCredentials_ReturnsTokenAndUser()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        var user = new UserEntity
        {
            Name = "Alice",
            Phone = "9000000000",
            PasswordHash = PasswordHasher.Hash("Correct@123"),
            Role = UserRole.Distributor,
            IsActive = true,
        };
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var service = new AuthService(db, NewTokenGenerator());
        var result = await service.LoginAsync(
            new LoginRequest { Phone = "9000000000", Password = "Correct@123" },
            CancellationToken.None);

        Assert.Equal(ResultStatus.Success, result.Status);
        Assert.NotNull(result.Value);
        Assert.False(string.IsNullOrEmpty(result.Value!.AccessToken));
        Assert.Equal("Alice", result.Value.User.Name);
        Assert.Equal(UserRole.Distributor, result.Value.User.Role);
    }

    [Fact]
    public async Task LoginAsync_WrongPassword_ReturnsValidationFailed()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        db.Users.Add(new UserEntity
        {
            Name = "Alice",
            Phone = "9000000000",
            PasswordHash = PasswordHasher.Hash("Correct@123"),
            Role = UserRole.Distributor,
            IsActive = true,
        });
        await db.SaveChangesAsync();

        var service = new AuthService(db, NewTokenGenerator());
        var result = await service.LoginAsync(
            new LoginRequest { Phone = "9000000000", Password = "Wrong@123" },
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
    }

    [Fact]
    public async Task LoginAsync_UnknownPhone_ReturnsValidationFailed()
    {
        using var testDb = TestDb.Create();
        var service = new AuthService(testDb.Context, NewTokenGenerator());

        var result = await service.LoginAsync(
            new LoginRequest { Phone = "0000000000", Password = "whatever" },
            CancellationToken.None);

        Assert.Equal(ResultStatus.ValidationFailed, result.Status);
    }

    [Fact]
    public async Task LoginAsync_DeactivatedAccount_ReturnsForbidden()
    {
        using var testDb = TestDb.Create();
        var db = testDb.Context;
        db.Users.Add(new UserEntity
        {
            Name = "Bob",
            Phone = "9111111111",
            PasswordHash = PasswordHasher.Hash("Correct@123"),
            Role = UserRole.User,
            IsActive = false,
        });
        await db.SaveChangesAsync();

        var service = new AuthService(db, NewTokenGenerator());
        var result = await service.LoginAsync(
            new LoginRequest { Phone = "9111111111", Password = "Correct@123" },
            CancellationToken.None);

        Assert.Equal(ResultStatus.Forbidden, result.Status);
    }

    [Fact]
    public void ALoginLastsThirtyMinutesUnlessConfiguredOtherwise()
    {
        var withoutSetting = new JwtTokenGenerator(new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> { ["Jwt:Key"] = "test-signing-key-at-least-32-characters-long" })
            .Build());
        var user = new UserEntity { Id = 1, Name = "A", Role = UserRole.User };

        var token = new System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler().ReadJwtToken(withoutSetting.GenerateToken(user));

        Assert.Equal(30, JwtTokenGenerator.DefaultExpiryMinutes);
        Assert.InRange((token.ValidTo - DateTime.UtcNow).TotalMinutes, 29, 30.1);
    }

    [Fact]
    public void TheApiShipsWith30MinutesInItsSettingsFile()
    {
        var path = Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "IDManager.Api", "appsettings.json");
        var json = System.Text.Json.JsonDocument.Parse(File.ReadAllText(path));

        Assert.Equal(30, json.RootElement.GetProperty("Jwt").GetProperty("ExpiryMinutes").GetInt32());
    }
}
