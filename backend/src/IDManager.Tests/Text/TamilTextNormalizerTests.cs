using IDManager.Infrastructure.Text;
using Xunit;

namespace IDManager.Tests.Text;

/// Text pulled out of a PDF comes in glyph (drawing) order: the vowel signs ெ ே ை that are
/// drawn to the LEFT of their consonant come before it. Unicode (and a text shaper) wants
/// them AFTER the consonant. The examples below are real words extracted from a member PDF.
public class TamilTextNormalizerTests
{
    [Theory]
    [InlineData("ெபயர்", "பெயர்")]                         // ெபயர்  -> பெயர்
    [InlineData("தந்ைத", "தந்தை")]                       // தந்ைத  -> தந்தை
    [InlineData("அட்ைட", "அட்டை")]                       // அட்ைட  -> அட்டை
    [InlineData("கைட", "கடை")]                                               // கைட    -> கடை (a syllable whose sign follows another consonant)
    [InlineData("வைக", "வகை")]                                               // வைக    -> வகை
    [InlineData("தைலவர்", "தலைவர்")]           // தைலவர் -> தலைவர்
    [InlineData("எண்ணிக்ைக", "எண்ணிக்கை")] // எண்ணிக்ைக -> எண்ணிக்கை
    [InlineData("நுகர்ேவார்", "நுகர்வோர்")]  // நுகர்ேவார் -> நுகர்வோர் (ே + வ + ா -> ோ)
    public void ConvertsGlyphOrderToLogicalOrder(string glyphOrder, string logical) =>
        Assert.Equal(logical, TamilTextNormalizer.GlyphOrderToLogical(glyphOrder));

    [Fact]
    public void TwoPartVowelsAreComposed()
    {
        // ப்ெபாருள்-style: ெ + ப + ா  ->  பொ (U+0BCA)
        var result = TamilTextNormalizer.GlyphOrderToLogical("உணவுப்ெபாருள்");
        Assert.Equal("உணவுப்பொருள்", result); // உணவுப்பொருள்
    }

    [Fact]
    public void ConvertsEveryWordOfASentence_AndKeepsSpacesAndLatinText()
    {
        // "தந்ைத / கணவர் ெபயர் 19G0140695"
        var input = "தந்ைத / கணவர் ெபயர் 19G0140695";
        var expected = "தந்தை / கணவர் பெயர் 19G0140695";
        Assert.Equal(expected, TamilTextNormalizer.GlyphOrderToLogical(input));
    }

    [Fact]
    public void ConjunctKshaKeepsItsSignAfterTheWholeConjunct()
    {
        // ெ + க்ஷ (க + ் + ஷ)  ->  க்ஷெ
        Assert.Equal("க்ஷெ", TamilTextNormalizer.GlyphOrderToLogical("ெக்ஷ"));
    }

    [Theory]
    [InlineData("")]
    [InlineData("Hello 123")]
    [InlineData("குடும்ப")]     // குடும்ப - no left-side vowel signs
    [InlineData("தமிழ்நாடு")] // தமிழ்நாடு
    public void TextWithoutLeftSideVowelSigns_IsUnchanged(string text) =>
        Assert.Equal(text, TamilTextNormalizer.GlyphOrderToLogical(text));

    [Fact]
    public void NullBecomesEmpty() => Assert.Equal("", TamilTextNormalizer.GlyphOrderToLogical(null));

    [Fact]
    public void ALeftSideSignWithNoConsonantAfterIt_IsLeftAlone()
    {
        Assert.Equal("ெ", TamilTextNormalizer.GlyphOrderToLogical("ெ"));
        Assert.Equal("ெ 12", TamilTextNormalizer.GlyphOrderToLogical("ெ 12"));
    }
}
