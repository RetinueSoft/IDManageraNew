using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IDManager.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddFileNamePattern : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "FileNamePattern",
                table: "CardTemplates",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FileNamePattern",
                table: "CardTemplates");
        }
    }
}
