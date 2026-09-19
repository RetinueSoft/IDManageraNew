using IDManager.Infrastructure;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;

namespace IDManager.Tests;

/// A real (SQLite, in-memory) database per test, not EF Core's InMemory provider -
/// several services (PointsService in particular) use `Database.BeginTransactionAsync`,
/// which the InMemory provider doesn't support at all.
public sealed class TestDb : IDisposable
{
    private readonly SqliteConnection _connection;
    public IDManagerDbContext Context { get; }

    private TestDb(SqliteConnection connection, IDManagerDbContext context)
    {
        _connection = connection;
        Context = context;
    }

    public static TestDb Create()
    {
        var connection = new SqliteConnection("Filename=:memory:");
        connection.Open();

        var options = new DbContextOptionsBuilder<IDManagerDbContext>()
            .UseSqlite(connection)
            .Options;
        var context = new IDManagerDbContext(options);
        context.Database.EnsureCreated();

        return new TestDb(connection, context);
    }

    public void Dispose()
    {
        Context.Dispose();
        _connection.Dispose();
    }
}
