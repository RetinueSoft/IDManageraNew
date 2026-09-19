using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IDManager.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddTextOrderVersion : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "TextOrderVersion",
                table: "IDCards",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "TextOrderVersion",
                table: "CardTemplates",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TextOrderVersion",
                table: "IDCards");

            migrationBuilder.DropColumn(
                name: "TextOrderVersion",
                table: "CardTemplates");
        }
    }
}
