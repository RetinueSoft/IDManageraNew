using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IDManager.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddUserProfileAndIdentity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "City",
                table: "Users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "IdNumber",
                table: "Users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "IdType",
                table: "Users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Pincode",
                table: "Users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ShopAddress",
                table: "Users",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ShopName",
                table: "Users",
                type: "text",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "UserIdentities",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    FrontImage = table.Column<byte[]>(type: "bytea", nullable: true),
                    BackImage = table.Column<byte[]>(type: "bytea", nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserIdentities", x => x.UserId);
                    table.ForeignKey(
                        name: "FK_UserIdentities_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UserIdentities");

            migrationBuilder.DropColumn(
                name: "City",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "IdNumber",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "IdType",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "Pincode",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "ShopAddress",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "ShopName",
                table: "Users");
        }
    }
}
