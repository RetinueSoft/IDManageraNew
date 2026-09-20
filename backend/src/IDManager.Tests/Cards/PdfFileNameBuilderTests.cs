using IDManager.Infrastructure.Cards;
using Xunit;

namespace IDManager.Tests.Cards;

public class PdfFileNameBuilderTests
{
    private static Dictionary<string, string> Values(params (string Key, string Value)[] pairs) =>
        pairs.ToDictionary(p => p.Key, p => p.Value);

    [Fact]
    public void FillsFieldsIntoThePattern()
    {
        var name = PdfFileNameBuilder.Build("{Name} - {Card No}", Values(("Name", "Ravi Kumar"), ("Card No", "1234567890")));

        Assert.Equal("Ravi Kumar - 1234567890", name);
    }

    [Fact]
    public void FieldNamesAreMatchedIgnoringCaseAndSpaces()
    {
        var name = PdfFileNameBuilder.Build("{ name }-{CARD   no}", Values(("Name", "Ravi"), ("card no", "42")));

        Assert.Equal("Ravi-42", name);
    }

    [Fact]
    public void ValuesAreTrimmed()
    {
        Assert.Equal("Ravi", PdfFileNameBuilder.Build("{Name}", Values(("Name", "  Ravi \n"))));
    }

    [Fact]
    public void ANameWithoutFieldsIsUsedAsWritten()
    {
        Assert.Equal("Member card", PdfFileNameBuilder.Build("Member card", Values()));
    }

    [Fact]
    public void TextAroundTheFieldsIsKept()
    {
        Assert.Equal("ID - Ravi (2024)", PdfFileNameBuilder.Build("ID - {Name} (2024)", Values(("Name", "Ravi"))));
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    public void NoPatternMeansNoName(string? pattern)
    {
        Assert.Null(PdfFileNameBuilder.Build(pattern, Values(("Name", "Ravi"))));
    }

    [Fact]
    public void WhenEveryFieldIsMissingThereIsNoName()
    {
        Assert.Null(PdfFileNameBuilder.Build("{Name} {Age}", Values(("Other", "x"))));
    }

    [Fact]
    public void AMissingFieldLeavesNoDanglingSeparator()
    {
        Assert.Equal("Ravi", PdfFileNameBuilder.Build("{Name} - {Card No}", Values(("Name", "Ravi"))));
        Assert.Equal("1234", PdfFileNameBuilder.Build("{Name} - {Card No}", Values(("Card No", "1234"))));
    }

    [Fact]
    public void BlankValuesCountAsMissing()
    {
        Assert.Equal("Ravi", PdfFileNameBuilder.Build("{Name}_{Card No}", Values(("Name", "Ravi"), ("Card No", "   "))));
    }

    [Fact]
    public void TheFirstValueOfAFieldWins()
    {
        var values = new List<KeyValuePair<string, string>> { new("Name", "First"), new("name", "Second") };

        Assert.Equal("First", PdfFileNameBuilder.Build("{Name}", values));
    }

    [Theory]
    [InlineData("01/01/1968", "01-01-1968")]
    [InlineData(@"a\b:c", "a-b-c")]
    [InlineData("what?*<>|\"", "what")]
    [InlineData("tab\there", "tab here")]
    [InlineData("many   spaces", "many spaces")]
    [InlineData("ends with dot.", "ends with dot")]
    public void CharactersNoFileSystemAllowsAreCleanedUp(string value, string expected)
    {
        Assert.Equal(expected, PdfFileNameBuilder.Build("{Field}", Values(("Field", value))));
    }

    [Theory]
    [InlineData("CON", "CON_")]
    [InlineData("nul", "nul_")]
    [InlineData("COM1", "COM1_")]
    [InlineData("CONSOLE", "CONSOLE")]
    public void WindowsReservedNamesAreAvoided(string value, string expected)
    {
        Assert.Equal(expected, PdfFileNameBuilder.Build("{Field}", Values(("Field", value))));
    }

    [Fact]
    public void TamilNamesAreKept()
    {
        Assert.Equal("ரவி குமார் - 117", PdfFileNameBuilder.Build("{பெயர்} - {எண்}", Values(("பெயர்", "ரவி குமார்"), ("எண்", "117"))));
    }

    [Fact]
    public void ALongNameIsShortened()
    {
        var name = PdfFileNameBuilder.Build("{Name}", Values(("Name", new string('a', 500))))!;

        Assert.Equal(PdfFileNameBuilder.MaxLength, name.Length);
    }

    [Fact]
    public void ShorteningNeverSplitsATamilLetter()
    {
        // Each "கு" is two code points; cutting at an odd length would leave a bare consonant sign pair broken.
        var long_ = string.Concat(Enumerable.Repeat("கு", 200));

        var name = PdfFileNameBuilder.Build("{Name}", Values(("Name", long_)))!;

        Assert.True(name.Length <= PdfFileNameBuilder.MaxLength);
        Assert.Equal(0, name.Length % 2);
        Assert.All(Enumerable.Range(0, name.Length / 2), i => Assert.Equal("கு", name.Substring(i * 2, 2)));
    }

    [Fact]
    public void FieldsInListsThePlaceholders()
    {
        Assert.Equal(["Name", "Card No"], PdfFileNameBuilder.FieldsIn("{Name} - { Card No } - x"));
        Assert.Empty(PdfFileNameBuilder.FieldsIn("plain"));
        Assert.Empty(PdfFileNameBuilder.FieldsIn(null));
        Assert.Empty(PdfFileNameBuilder.FieldsIn("{}"));
    }
}
