using System.Text;
using System.Text.RegularExpressions;

namespace IDManager.Infrastructure.Text;

/// Prints a date value in the format a layer names, e.g. "01-Jan-1968" as "01/01/1968" for
/// dd/MM/yyyy. A value that is not a plain date (a postcode, a phone number, a date with a time,
/// an impossible date like 31-Feb) is returned exactly as it was. The Flutter app has the same
/// function (date_formatter.dart) and the same tests: the designer and the printed PDF must
/// format dates identically.
///
/// Recognised inputs, day first (so 05/03/2021 is 5 March): dd-MM-yyyy (separators - / . or
/// space), yyyy-MM-dd, dd-MMM-yyyy and dd MMMM yyyy (English month names, any case), and
/// "MMM d, yyyy".
///
/// Format tokens: yyyy, yy, MMMM, MMM, MM, M, dd, d. Everything else is printed as typed.
public static class DateValueFormatter
{
    private static readonly string[] Months =
    [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December",
    ];

    // Longest first, so "MMMM" is read before "MMM", "MM" and "M".
    private static readonly string[] Tokens = ["yyyy", "MMMM", "MMM", "MM", "dd", "yy", "M", "d"];

    private static readonly Regex DayMonthYearNumeric = new(@"^([0-9]{1,2})[-/. ]([0-9]{1,2})[-/. ]([0-9]{4})$", RegexOptions.CultureInvariant);
    private static readonly Regex YearMonthDayNumeric = new(@"^([0-9]{4})[-/.]([0-9]{1,2})[-/.]([0-9]{1,2})$", RegexOptions.CultureInvariant);
    private static readonly Regex DayMonthNameYear = new(@"^([0-9]{1,2})[-/. ]+([A-Za-z]+)[-/. ]+([0-9]{4})$", RegexOptions.CultureInvariant);
    private static readonly Regex MonthNameDayYear = new(@"^([A-Za-z]+)\.? +([0-9]{1,2}),? +([0-9]{4})$", RegexOptions.CultureInvariant);

    /// [value] as a date in [format], or [value] itself when it is not a date or [format] has no
    /// date parts.
    public static string Reformat(string value, string? format)
    {
        if (string.IsNullOrWhiteSpace(value) || !IsUsable(format)) return value;

        var date = Parse(value.Trim());
        return date is { } d ? Format(d.Year, d.Month, d.Day, format!) : value;
    }

    /// A fixed sample date (7 March 2024) in [format], or null if [format] has no date parts.
    public static string? Example(string? format) => IsUsable(format) ? Format(2024, 3, 7, format!) : null;

    public static bool IsUsable(string? format) =>
        !string.IsNullOrWhiteSpace(format) && Tokens.Any(t => format.Contains(t, StringComparison.Ordinal));

    private static (int Year, int Month, int Day)? Parse(string text)
    {
        var m = DayMonthYearNumeric.Match(text);
        if (m.Success) return Valid(int.Parse(m.Groups[3].Value), int.Parse(m.Groups[2].Value), int.Parse(m.Groups[1].Value));

        m = YearMonthDayNumeric.Match(text);
        if (m.Success) return Valid(int.Parse(m.Groups[1].Value), int.Parse(m.Groups[2].Value), int.Parse(m.Groups[3].Value));

        m = DayMonthNameYear.Match(text);
        if (m.Success && MonthNumber(m.Groups[2].Value) is { } month1)
            return Valid(int.Parse(m.Groups[3].Value), month1, int.Parse(m.Groups[1].Value));

        m = MonthNameDayYear.Match(text);
        if (m.Success && MonthNumber(m.Groups[1].Value) is { } month2)
            return Valid(int.Parse(m.Groups[3].Value), month2, int.Parse(m.Groups[2].Value));

        return null;
    }

    private static (int, int, int)? Valid(int year, int month, int day)
    {
        if (year < 1 || month < 1 || month > 12 || day < 1) return null;
        return day <= DateTime.DaysInMonth(year, month) ? (year, month, day) : null;
    }

    /// 1-12 for a full English month name or its 3-letter abbreviation, any case; else null.
    private static int? MonthNumber(string name)
    {
        for (var i = 0; i < Months.Length; i++)
        {
            if (name.Equals(Months[i], StringComparison.OrdinalIgnoreCase)
                || name.Equals(Months[i][..3], StringComparison.OrdinalIgnoreCase))
            {
                return i + 1;
            }
        }

        return null;
    }

    private static string Format(int year, int month, int day, string format)
    {
        var result = new StringBuilder();
        for (var i = 0; i < format.Length;)
        {
            var token = Tokens.FirstOrDefault(t => string.CompareOrdinal(format, i, t, 0, t.Length) == 0);
            if (token is null)
            {
                result.Append(format[i++]);
                continue;
            }

            result.Append(token switch
            {
                "yyyy" => year.ToString("D4"),
                "yy" => (year % 100).ToString("D2"),
                "MMMM" => Months[month - 1],
                "MMM" => Months[month - 1][..3],
                "MM" => month.ToString("D2"),
                "M" => month.ToString(),
                "dd" => day.ToString("D2"),
                _ => day.ToString(), // "d"
            });
            i += token.Length;
        }

        return result.ToString();
    }
}
