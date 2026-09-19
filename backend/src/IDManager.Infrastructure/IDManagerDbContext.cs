using IDManager.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Infrastructure;

public class IDManagerDbContext : DbContext
{
    public IDManagerDbContext(DbContextOptions<IDManagerDbContext> options) : base(options) { }

    public DbSet<UserEntity> Users => Set<UserEntity>();
    public DbSet<PointTransactionEntity> PointTransactions => Set<PointTransactionEntity>();
    public DbSet<AuditLogEntity> AuditLogs => Set<AuditLogEntity>();
    public DbSet<CardTemplateEntity> CardTemplates => Set<CardTemplateEntity>();
    public DbSet<TemplateCombinationEntity> TemplateCombinations => Set<TemplateCombinationEntity>();
    public DbSet<IDCardEntity> IDCards => Set<IDCardEntity>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserEntity>(e =>
        {
            e.HasIndex(u => u.Phone).IsUnique();
        });

        modelBuilder.Entity<CardTemplateEntity>(e =>
        {
            e.HasMany(t => t.Combinations)
                .WithOne(c => c.Template)
                .HasForeignKey(c => c.TemplateId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        base.OnModelCreating(modelBuilder);
    }
}
