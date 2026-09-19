using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IDManager.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RetireAdminRole : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // The Admin role (2) was removed - see docs/member-hierarchy.md. Existing
            // Admins become Distributors (3), the closest remaining role.
            migrationBuilder.Sql("UPDATE \"Users\" SET \"Role\" = 3 WHERE \"Role\" = 2;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
