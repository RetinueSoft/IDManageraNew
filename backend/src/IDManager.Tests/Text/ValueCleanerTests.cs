using IDManager.Infrastructure.Text;
using Xunit;

namespace IDManager.Tests.Text;

/// A layer can list words to strip out of its values (e.g. "எண்" from "எண் :117 கூளமடை").
/// The same cases are tested in the Flutter app (value_cleaner_test.dart): the designer and
/// the printed PDF must clean values identically.
public class ValueCleanerTests
{
    [Fact]
    public void RemovesTheWord_AndTidiesWhatIsLeftBehind()
    {
        // "எண் :117 கூளமடை" -> "117 கூளமடை": the word goes, and so does the ":" it leaves at the start.
        Assert.Equal("117 கூளமடை", ValueCleaner.RemoveWords("எண் :117 கூளமடை", ["எண்"]));
    }

    [Fact]
    public void OnlyWholeWordsAreRemoved()
    {
        // "எண்ணிக்கை" starts with "எண்" but is a different word.
        Assert.Equal("எண்ணிக்கை 3", ValueCleaner.RemoveWords("எண்ணிக்கை 3", ["எண்"]));
        Assert.Equal("Palace Colony", ValueCleaner.RemoveWords("Palace No Colony", ["No"]));
        Assert.Equal("Number 5", ValueCleaner.RemoveWords("Number 5", ["No"]));
    }

    [Fact]
    public void SeveralWordsCanBeRemoved()
    {
        Assert.Equal("117 கூளமடை", ValueCleaner.RemoveWords("எண் :117 கூளமடை போஸ்ட்", ["எண்", "போஸ்ட்"]));
    }

    [Fact]
    public void EveryOccurrenceIsRemoved()
    {
        Assert.Equal("A B", ValueCleaner.RemoveWords("X A X B X", ["X"]));
    }

    [Fact]
    public void LatinWordsMatchRegardlessOfCase()
    {
        Assert.Equal("117 Palace", ValueCleaner.RemoveWords("NO. 117 Palace", ["no."]));
    }

    [Fact]
    public void APhraseWithSpacesCanBeRemoved()
    {
        Assert.Equal("Colony", ValueCleaner.RemoveWords("Door No Colony", ["Door No"]));
    }

    [Fact]
    public void ARemovedWordBetweenCommas_DoesNotLeaveADoubleComma()
    {
        Assert.Equal("MG Road, Pune", ValueCleaner.RemoveWords("MG Road, X, Pune", ["X"]));
    }

    [Fact]
    public void RemovingEverything_LeavesAnEmptyValue() =>
        Assert.Equal("", ValueCleaner.RemoveWords("எண்", ["எண்"]));

    [Theory]
    [InlineData("117 கூளமடை.")]      // punctuation is only tidied when something was actually removed
    [InlineData(" spaced  out ")]
    [InlineData(": 5 -")]
    public void AValueThatHasNoneOfTheWords_IsReturnedUntouched(string value) =>
        Assert.Equal(value, ValueCleaner.RemoveWords(value, ["எண்", "No"]));

    [Fact]
    public void NoWords_NullOrBlankWords_LeaveTheValueAlone()
    {
        Assert.Equal("எண் 5", ValueCleaner.RemoveWords("எண் 5", []));
        Assert.Equal("எண் 5", ValueCleaner.RemoveWords("எண் 5", null));
        Assert.Equal("எண் 5", ValueCleaner.RemoveWords("எண் 5", ["", "  "]));
    }

    [Fact]
    public void WordsWithRegexCharactersAreTakenLiterally()
    {
        Assert.Equal("A B", ValueCleaner.RemoveWords("A (x) B", ["(x)"]));
        Assert.Equal("A B", ValueCleaner.RemoveWords("A B", ["."]));   // "." is not a wildcard
    }

    [Fact]
    public void WordsAreTrimmed() =>
        Assert.Equal("117 கூளமடை", ValueCleaner.RemoveWords("எண் :117 கூளமடை", ["  எண்  "]));
}
