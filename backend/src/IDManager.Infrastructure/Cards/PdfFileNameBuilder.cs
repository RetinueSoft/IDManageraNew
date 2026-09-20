using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace IDManager.Infrastructure.Cards;

/// Builds the name a downloaded card PDF is saved as from a template's file name pattern, e.g.
/// "{Name} - {Ration Card No}" with the member's field values filled in. A {Field} is looked up
/// by the name of the PDF field (ignoring case and extra spaces, like layer keys are); a field the
/// member's PDF does not have simply leaves nothing. The result is safe to use as a file name on
/// Windows, macOS and Linux.
public static partial class PdfFileNameBuilder
{
    /// Long enough for a name and a number, short enough for every file system and path.
    public const int MaxLength = 100;

    [GeneratedRegex(@"\{([^{}]*)\}")]
    private static partial Regex Placeholder();

    [GeneratedRegex(@"\s+")]
    private static partial Regex Spaces();

    private static readonly HashSet<string> ReservedWindowsNames = new(StringComparer.OrdinalIgnoreCase)
    {
        "CON", "PRN", "AUX", "NUL",
        "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
        "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9",
    };

    /// The file name (without ".pdf") for [pattern] with [values] (PDF field name -> value) filled
    /// in, or null when there is no pattern or nothing usable is left - the caller then falls back
    /// to its own name.
    public static string? Build(string? pattern, IEnumerable<KeyValuePair<string, string>> values)
    {
        if (string.IsNullOrWhiteSpace(pattern)) return null;

        var byKey = new Dictionary<string, string>();
        foreach (var (key, value) in values)
        {
            var normalized = NormalizeKey(key);
            if (normalized.Length == 0 || string.IsNullOrWhiteSpace(value)) continue;
            byKey.TryAdd(normalized, value);
        }

        var filled = Placeholder().Replace(pattern, match =>
            byKey.TryGetValue(NormalizeKey(match.Groups[1].Value), out var value) ? value.Trim() : "");

        var name = Sanitize(filled);
        return name.Length == 0 ? null : name;
    }

    /// The field names a pattern refers to, in order ("{Name} - {Age}" gives Name, Age).
    public static IReadOnlyList<string> FieldsIn(string? pattern) =>
        string.IsNullOrEmpty(pattern)
            ? []
            : Placeholder().Matches(pattern).Select(m => m.Groups[1].Value.Trim()).Where(k => k.Length > 0).ToList();

    /// Makes [text] a valid file name: characters no file system allows are replaced or dropped,
    /// runs of spaces collapse, and separators left dangling by an empty field are trimmed.
    public static string Sanitize(string text)
    {
        var builder = new StringBuilder(text.Length);
        foreach (var c in text)
        {
            if (c is '/' or '\\' or ':') builder.Append('-');
            else if (c is '*' or '?' or '"' or '<' or '>' or '|') continue;
            else if (char.IsControl(c)) builder.Append(' ');
            else builder.Append(c);
        }

        var name = Spaces().Replace(builder.ToString(), " ").Trim();
        name = Truncate(name, MaxLength);
        // Nothing dangling at the ends: "Ravi - " (the second field was empty), a trailing dot
        // (Windows drops it) ...
        name = name.Trim(' ', '-', '_', ',', '.', ';');

        if (ReservedWindowsNames.Contains(name)) name += "_";
        return name;
    }

    /// At most [max] characters as the reader sees them - never cutting a Tamil letter (a base
    /// with its vowel signs) in half.
    private static string Truncate(string text, int max)
    {
        if (text.Length <= max) return text;
        var result = new StringBuilder();
        var elements = StringInfo.GetTextElementEnumerator(text);
        while (elements.MoveNext())
        {
            var element = (string)elements.Current;
            if (result.Length + element.Length > max) break;
            result.Append(element);
        }
        return result.ToString();
    }

    private static string NormalizeKey(string? key) =>
        Spaces().Replace((key ?? "").Trim(), " ").ToLowerInvariant();
}
