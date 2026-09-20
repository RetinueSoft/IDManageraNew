using IDManager.Infrastructure.Text;
using Xunit;

namespace IDManager.Tests.Text;

/// A layer can name a date format (e.g. dd/MM/yyyy): a value that is a date is printed in that
/// format, anything else is left alone. The same cases are tested in the Flutter app
/// (date_formatter_test.dart): the designer and the printed PDF must format dates identically.
public class DateValueFormatterTests
{
    [Theory]
    [InlineData("01-Jan-1968", "dd/MM/yyyy", "01/01/1968")]        // the case from the member PDF
    [InlineData("26-Jul-1972", "dd/MM/yyyy", "26/07/1972")]
    [InlineData("01/01/1968", "dd-MMM-yyyy", "01-Jan-1968")]
    [InlineData("31-12-2020", "yyyy-MM-dd", "2020-12-31")]
    [InlineData("1968-01-31", "dd/MM/yyyy", "31/01/1968")]        // year first
    [InlineData("09 December 2023", "dd/MM/yyyy", "09/12/2023")]  // full month name
    [InlineData("Jan 5, 2020", "dd/MM/yyyy", "05/01/2020")]       // month first with a comma
    [InlineData("5.3.2021", "dd/MM/yyyy", "05/03/2021")]          // dots, no zero padding
    [InlineData(" 01-Jan-1968 ", "dd/MM/yyyy", "01/01/1968")]     // surrounding spaces
    [InlineData("01-JAN-1968", "dd/MM/yyyy", "01/01/1968")]       // any case
    [InlineData("01-january-1968", "dd/MM/yyyy", "01/01/1968")]
    public void ReformatsADateValue(string value, string format, string expected) =>
        Assert.Equal(expected, DateValueFormatter.Reformat(value, format));

    [Theory]
    [InlineData("dd/MM/yyyy", "07/03/2024")]
    [InlineData("d/M/yyyy", "7/3/2024")]
    [InlineData("dd-MMM-yyyy", "07-Mar-2024")]
    [InlineData("dd MMMM yyyy", "07 March 2024")]
    [InlineData("d MMMM yyyy", "7 March 2024")]
    [InlineData("MM/dd/yyyy", "03/07/2024")]
    [InlineData("yyyy-MM-dd", "2024-03-07")]
    [InlineData("dd MMM yy", "07 Mar 24")]
    [InlineData("MMMM d, yyyy", "March 7, 2024")]
    public void SupportsTheUsualFormatTokens(string format, string expected) =>
        Assert.Equal(expected, DateValueFormatter.Reformat("07-Mar-2024", format));

    [Theory]
    [InlineData("614001")]                       // a postcode
    [InlineData("9876543210")]                   // a phone number
    [InlineData("01-Jan-1968 10:30")]            // has a time: not a plain date
    [InlineData("09 December 2023 | 03:42:37 PM")]
    [InlineData("31-Feb-2020")]                  // not a real date
    [InlineData("32/01/2020")]
    [InlineData("hello")]
    [InlineData("")]
    [InlineData("26-Jul-1972 extra")]
    [InlineData("Foo 5, 2020")]                  // not a month
    public void AValueThatIsNotADate_IsLeftAlone(string value) =>
        Assert.Equal(value, DateValueFormatter.Reformat(value, "dd/MM/yyyy"));

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData("hello")]        // a format with no date parts would print the same text for every date
    [InlineData("/ - ")]
    public void NoUsableFormat_LeavesTheValueAlone(string? format) =>
        Assert.Equal("01-Jan-1968", DateValueFormatter.Reformat("01-Jan-1968", format));

    [Fact]
    public void ADateThatIsAlreadyInTheFormat_StaysTheSame() =>
        Assert.Equal("01/01/1968", DateValueFormatter.Reformat("01/01/1968", "dd/MM/yyyy"));

    [Fact]
    public void ALeapDayIsAcceptedAndAnImpossibleOneIsNot()
    {
        Assert.Equal("29/02/2020", DateValueFormatter.Reformat("29-Feb-2020", "dd/MM/yyyy"));
        Assert.Equal("29-Feb-2021", DateValueFormatter.Reformat("29-Feb-2021", "dd/MM/yyyy"));
    }
}
