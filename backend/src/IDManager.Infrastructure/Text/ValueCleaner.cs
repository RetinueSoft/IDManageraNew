using System.Text.RegularExpressions;

namespace IDManager.Infrastructure.Text;

/// Strips a layer's "words to remove" out of a value, e.g. "எண்" from "எண் :117 கூளமடை" so the
/// card prints "117 கூளமடை". The Flutter app has the same function (value_cleaner.dart) and
/// the same tests: the designer and the printed PDF must clean values identically.
///
/// Only WHOLE words are removed - "எண்" is not taken out of "எண்ணிக்கை" - where a word is a run
/// of letters, combining marks (Tamil vowel signs are marks) and digits. A regex \b is not used
/// because it does not treat Tamil's spacing marks as word characters. Matching ignores case.
public static class ValueCleaner
{
    private const string WordChar = @"[\p{L}\p{M}\p{N}]";

    /// Returns [value] with every occurrence of each word in [words] removed, then tidied:
    /// runs of spaces collapse, doubled commas left by a removed word collapse, and separators
    /// (: , ; . -) are trimmed from both ends. A value that contains none of the words is
    /// returned exactly as it was, punctuation and all.
    public static string RemoveWords(string value, IEnumerable<string>? words)
    {
        if (string.IsNullOrEmpty(value) || words is null) return value;

        var result = value;
        var changed = false;
        foreach (var raw in words)
        {
            var word = raw?.Trim();
            if (string.IsNullOrEmpty(word)) continue;

            var pattern = new Regex(
                $"(?<!{WordChar}){Regex.Escape(word)}(?!{WordChar})",
                RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
            if (!pattern.IsMatch(result)) continue;

            result = pattern.Replace(result, "");
            changed = true;
        }

        return changed ? Tidy(result) : value;
    }

    private static string Tidy(string text)
    {
        text = Regex.Replace(text, @"\s+", " ");
        text = Regex.Replace(text, @",(\s*,)+", ",");
        return text.Trim(' ', ':', ',', ';', '.', '-');
    }
}
