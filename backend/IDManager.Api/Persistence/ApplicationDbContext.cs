using IDManager.Api.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Api.Persistence;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<PointTransaction> PointTransactions => Set<PointTransaction>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
    public DbSet<CardTemplate> CardTemplates => Set<CardTemplate>();
    public DbSet<TemplateCombination> TemplateCombinations => Set<TemplateCombination>();
    public DbSet<IDCard> IDCards => Set<IDCard>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(e =>
        {
            e.HasIndex(u => u.Phone).IsUnique();
        });

        modelBuilder.Entity<CardTemplate>(e =>
        {
            e.HasMany(t => t.Combinations)
                .WithOne(c => c.Template)
                .HasForeignKey(c => c.TemplateId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        base.OnModelCreating(modelBuilder);
    }
}
