using System.Text;

namespace IDManager.Infrastructure.Text;

/// Text extracted from a PDF is in glyph (drawing) order. In Tamil three vowel signs are
/// drawn to the LEFT of their consonant - ெ (U+0BC6), ே (U+0BC7) and ை (U+0BC8) - so a PDF
/// stores them BEFORE it, and extraction returns "ெபயர்" for பெயர். Unicode - and any text
/// shaper - expects them AFTER the consonant.
///
/// Apply GlyphOrderToLogical exactly once, to text that came out of a PDF. It is NOT
/// idempotent: run on text already in logical order it would move the signs a second time.
public static class TamilTextNormalizer
{
    private const char SignE = 'ெ';
    private const char SignEE = 'ே';
    private const char SignAI = 'ை';
    private const char Virama = '்';
    private const char Ka = 'க';
    private const char Ssa = 'ஷ';

    private static bool IsLeftSideSign(char c) => c is SignE or SignEE or SignAI;
    private static bool IsConsonant(char c) => c is >= 'க' and <= 'ஹ';

    /// Moves every left-side vowel sign to after the consonant it belongs to (the next
    /// consonant; the conjunct க்ஷ counts as one), then composes the two-part vowels
    /// (ெ + ா -> ொ, ே + ா -> ோ, ெ + ௗ -> ௌ).
    public static string GlyphOrderToLogical(string? text)
    {
        if (string.IsNullOrEmpty(text)) return "";
        if (!text.Any(IsLeftSideSign)) return text;

        var result = new StringBuilder(text.Length);
        for (var i = 0; i < text.Length; i++)
        {
            var c = text[i];
            if (IsLeftSideSign(c) && i + 1 < text.Length && IsConsonant(text[i + 1]))
            {
                var end = i + 2; // just past the consonant
                if (text[i + 1] == Ka && end + 1 < text.Length && text[end] == Virama && text[end + 1] == Ssa)
                {
                    end += 2; // க்ஷ
                }

                result.Append(text, i + 1, end - (i + 1)).Append(c);
                i = end - 1;
                continue;
            }

            result.Append(c);
        }

        return result.ToString().Normalize(NormalizationForm.FormC);
    }
}
