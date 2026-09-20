using System.Text;
using IDManager.Api.Endpoints;
using IDManager.Domain.Entities;
using IDManager.Domain.Enums;
using IDManager.Infrastructure;
using IDManager.Infrastructure.AuditLog;
using IDManager.Infrastructure.Cards;
using IDManager.Infrastructure.Points;
using IDManager.Infrastructure.Security;
using IDManager.Infrastructure.Templates;
using IDManager.Infrastructure.Text;
using IDManager.Infrastructure.Users;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<IDManagerDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Default")
        ?? throw new InvalidOperationException("Missing ConnectionStrings:Default.")));

// Infrastructure services - each is a thin, stateless wrapper over the DbContext, so
// scoped (one instance per request) is the right lifetime throughout.
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<UserService>();
builder.Services.AddScoped<PointsService>();
builder.Services.AddScoped<IDManager.Infrastructure.Dashboard.DashboardService>();
builder.Services.AddScoped<TemplateService>();
builder.Services.AddScoped<CardService>();
builder.Services.AddScoped<AuditLogService>();
builder.Services.AddSingleton<PdfExtractionService>();
// The card PDF page is the card scaled up by Pdf:PageScale (default 3; 1 = exact card size).
builder.Services.AddSingleton(sp => new PdfGenerationService(
    sp.GetRequiredService<IConfiguration>().GetValue("Pdf:PageScale", PdfGenerationService.DefaultPageScale)));
builder.Services.AddSingleton<JwtTokenGenerator>();

var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy => policy.WithOrigins(allowedOrigins).AllowAnyHeader().AllowAnyMethod().WithExposedHeaders("X-File-Name", "Content-Disposition"));
});

var jwtKey = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key is not configured.");
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = false,
            ValidateAudience = false,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ClockSkew = TimeSpan.Zero,
        };
    });
builder.Services.AddAuthorization();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "IDManager API", Version = "v1" });
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] then your token.",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
    });
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        { new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } }, [] },
    });
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<IDManagerDbContext>();
    await db.Database.MigrateAsync();

    // One-time: turn Tamil text saved in glyph order into logical order (each row is marked, so
    // this never converts anything twice).
    var (convertedTemplates, convertedCards) = await new TextOrderMigrationService(db).RunAsync(CancellationToken.None);
    if (convertedTemplates + convertedCards > 0)
    {
        app.Logger.LogInformation("Converted Tamil text order for {Templates} template(s) and {Cards} card(s).", convertedTemplates, convertedCards);
    }

    // Bootstraps the role hierarchy on a brand new database - without this there
    // would be no way to log in and create the first Distributor/Retailer accounts.
    if (!await db.Users.AnyAsync())
    {
        db.Users.Add(new UserEntity
        {
            Name = "Super Admin",
            Phone = builder.Configuration["SeedAdmin:Phone"] ?? "9999999999",
            PasswordHash = PasswordHasher.Hash(builder.Configuration["SeedAdmin:Password"] ?? "Admin@123"),
            Role = UserRole.SuperAdmin,
            IsActive = true,
        });
        await db.SaveChangesAsync();
    }
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors();
app.UseAuthentication();
app.UseAuthorization();

app.MapAuthEndpoints();
app.MapUserEndpoints();
app.MapTemplateEndpoints();
app.MapCardEndpoints();
app.MapPointsEndpoints();
app.MapDashboardEndpoints();
app.MapAuditLogEndpoints();

app.Run();

/// Exposed for WebApplicationFactory-based integration tests.
public partial class Program;
