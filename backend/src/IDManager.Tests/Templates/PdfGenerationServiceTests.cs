using IDManager.Domain.Dtos;
using IDManager.Domain.Enums;
using IDManager.Infrastructure.Templates;
using UglyToad.PdfPig;

namespace IDManager.Tests.Templates;

public class PdfGenerationServiceTests
{
    private const double MmToPt = 72.0 / 25.4;
    private const double CardHeightMm = 54;

    // A 1x1 PNG, used as the card background.
    private static readonly byte[] Png = Convert.FromBase64String(
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==");

    private static byte[] Render(LayerGroupDto group) => new PdfGenerationService().GenerateCardPdf(
        Png, Png, 85.6, CardHeightMm,
        [new TemplateLayerDto { Side = CardSide.Front, Groups = [group] }]);

    [Fact]
    public void AlignedBulletList_PutsValuesAfterTheKeyColumnAndGrowsDownward()
    {
        var group = new LayerGroupDto
        {
            IsList = true, BulletList = true, XMm = 10, YMm = 10, WidthMm = 60, KeyWidthMm = 20, FontSizePt = 10,
            Sources =
            [
                new LayerSourceItemDto { Key = "Street", Value = "MGRoad" },
                new LayerSourceItemDto { Key = "City", Value = "Pune" },
            ],
        };

        using var pdf = PdfDocument.Open(Render(group));
        var words = pdf.GetPage(1).GetWords().ToList();
        var street = words.First(w => w.Text == "Street").BoundingBox;
        var city = words.First(w => w.Text == "City").BoundingBox;
        var mgRoad = words.First(w => w.Text == "MGRoad").BoundingBox;
        var pune = words.First(w => w.Text == "Pune").BoundingBox;

        // Values start after the 20mm key column (plus the separator), not right after the key.
        Assert.True(mgRoad.Left - street.Left > 45, $"value column offset was {mgRoad.Left - street.Left}");
        Assert.Equal(mgRoad.Left, pune.Left, 1);

        // Anchored at the top: the first row sits just below Y = 10mm, and the second is lower.
        var topOfCardPt = CardHeightMm * MmToPt;
        var anchorPt = topOfCardPt - 10 * MmToPt;
        Assert.InRange(street.Top, anchorPt - 15, anchorPt + 1);
        Assert.True(city.Top < street.Bottom + 1, "second row should be below the first");
    }

    [Fact]
    public void MultiLineList_GrowsDownwardFromY()
    {
        var group = new LayerGroupDto
        {
            IsList = true, BulletList = true, XMm = 10, YMm = 10, WidthMm = 60, FontSizePt = 10,
            Sources =
            [
                new LayerSourceItemDto { Value = "First" },
                new LayerSourceItemDto { Value = "Second" },
                new LayerSourceItemDto { Value = "Third" },
            ],
        };

        using var pdf = PdfDocument.Open(Render(group));
        var words = pdf.GetPage(1).GetWords().ToList();
        var first = words.First(w => w.Text == "First").BoundingBox;
        var third = words.First(w => w.Text == "Third").BoundingBox;

        var anchorPt = CardHeightMm * MmToPt - 10 * MmToPt;
        Assert.InRange(first.Top, anchorPt - 15, anchorPt + 1);
        Assert.True(third.Top < first.Bottom, "third line should be below the first");
    }

    [Fact]
    public void ImageLayer_IsStretchedToItsWidthAndHeight()
    {
        // A 1x1 (square) image in a 40 x 10 mm box: aspect-fit would give 10 x 10 mm.
        var group = new LayerGroupDto
        {
            FieldType = LayerFieldType.Image, XMm = 10, YMm = 10, WidthMm = 40, HeightMm = 10,
            Sources = [new LayerSourceItemDto { Type = LayerFieldType.Image, Value = Convert.ToBase64String(Png) }],
        };

        using var pdf = PdfDocument.Open(Render(group));
        var image = pdf.GetPage(1).GetImages().Single(i => i.Bounds.Width < 200); // skip the full-card background

        Assert.Equal(40 * MmToPt, image.Bounds.Width, 0);
        Assert.Equal(10 * MmToPt, image.Bounds.Height, 0);
    }

    [Fact]
    public void KeyWidth_AlignsValuesEvenWithoutBullets()
    {
        var group = new LayerGroupDto
        {
            IsList = true, BulletList = false, XMm = 10, YMm = 10, WidthMm = 60, KeyWidthMm = 20, FontSizePt = 10,
            Sources =
            [
                new LayerSourceItemDto { Key = "Name", Value = "Asha", Separator = "newline" },
                new LayerSourceItemDto { Key = "Village", Value = "Pune" },
            ],
        };

        using var pdf = PdfDocument.Open(Render(group));
        var page = pdf.GetPage(1);
        var words = page.GetWords().ToList();
        var name = words.First(w => w.Text == "Name").BoundingBox;
        var village = words.First(w => w.Text == "Village").BoundingBox;
        var asha = words.First(w => w.Text == "Asha").BoundingBox;
        var pune = words.First(w => w.Text == "Pune").BoundingBox;

        Assert.DoesNotContain("•", page.Text);
        Assert.Equal(name.Left, village.Left, 1);            // keys share the column's left edge
        Assert.Equal(asha.Left, pune.Left, 1);               // values line up
        Assert.True(asha.Left - name.Left > 50, "value should start after the 20mm key column");
        Assert.True(village.Top < name.Bottom + 1, "second field should be on its own row below the first");
    }

    [Fact]
    public void LineGap_AddsExtraSpaceBetweenAllLines()
    {
        static LayerGroupDto Group(double gapMm) => new()
        {
            IsList = true, XMm = 10, YMm = 10, WidthMm = 60, FontSizePt = 10, LineGapMm = gapMm,
            Sources =
            [
                new LayerSourceItemDto { Value = "First", Separator = "newline" },
                new LayerSourceItemDto { Value = "Second", Separator = "newline" },
                new LayerSourceItemDto { Value = "Third" },
            ],
        };

        static double Pitch(byte[] pdfBytes)
        {
            using var pdf = PdfDocument.Open(pdfBytes);
            var words = pdf.GetPage(1).GetWords().ToList();
            return words.First(w => w.Text == "First").BoundingBox.Bottom - words.First(w => w.Text == "Second").BoundingBox.Bottom;
        }

        var normal = Pitch(Render(Group(0)));
        var gapped = Pitch(Render(Group(5)));

        Assert.Equal(5 * MmToPt, gapped - normal, 0);
    }

    [Fact]
    public void EachSidesLayersAreDrawnOnThatSidesPage()
    {
        // Layers of every kind on the back: a plain text, an aligned list (table), a combined
        // paragraph and an image. None of them may end up on page 1 (the front).
        static LayerGroupDto Text(string value) => new()
        {
            XMm = 5, YMm = 5, WidthMm = 40, FontSizePt = 10,
            Sources = [new LayerSourceItemDto { Key = "K", Value = value }],
        };
        var backAligned = new LayerGroupDto
        {
            IsList = true, XMm = 5, YMm = 15, WidthMm = 60, KeyWidthMm = 20, FontSizePt = 10,
            Sources = [new LayerSourceItemDto { Key = "Row", Value = "AlignedBack" }],
        };
        var backCombined = new LayerGroupDto
        {
            IsList = true, XMm = 5, YMm = 25, WidthMm = 60, FontSizePt = 10,
            Sources = [new LayerSourceItemDto { Value = "CombinedBack" }],
        };
        var backImage = new LayerGroupDto
        {
            FieldType = LayerFieldType.Image, XMm = 30, YMm = 30, WidthMm = 19, HeightMm = 19,
            Sources = [new LayerSourceItemDto { Type = LayerFieldType.Image, Value = Convert.ToBase64String(Png) }],
        };

        var bytes = new PdfGenerationService().GenerateCardPdf(Png, Png, 85.6, CardHeightMm,
        [
            new TemplateLayerDto { Side = CardSide.Front, Groups = [Text("OnFront")] },
            new TemplateLayerDto { Side = CardSide.Back, Groups = [Text("OnBack"), backAligned, backCombined, backImage] },
        ]);

        using var pdf = PdfDocument.Open(bytes);
        var front = pdf.GetPage(1);
        var back = pdf.GetPage(2);

        Assert.Contains("OnFront", front.Text);
        foreach (var backText in new[] { "OnBack", "AlignedBack", "CombinedBack" })
        {
            Assert.DoesNotContain(backText, front.Text);
            Assert.Contains(backText, back.Text);
        }
        Assert.DoesNotContain("OnFront", back.Text);
        Assert.Single(front.GetImages());       // just the background
        Assert.Equal(2, back.GetImages().Count()); // background + the back's image layer
    }

    // ---- Tamil (shaped with HarfBuzz using the embedded Noto Sans Tamil) ----

    private const string TamilName = "பெயர்";                                  // பெயர்
    private const string TamilFamily = "குடும்ப அட்டை"; // குடும்ப அட்டை

    private static LayerGroupDto TextLayer(string key, string value, double widthMm = 60, bool bold = false) => new()
    {
        XMm = 5, YMm = 5, WidthMm = widthMm, FontSizePt = 10, Bold = bold,
        Sources = [new LayerSourceItemDto { Key = key, Value = value }],
    };

    [Fact]
    public void TamilText_IsPrinted_InTheTamilFont()
    {
        using var pdf = PdfDocument.Open(Render(TextLayer(TamilName, TamilFamily)));
        var letters = pdf.GetPage(1).Letters;

        // Before this fix the PDF library had no Tamil glyphs, so every Tamil character was missing.
        Assert.Contains(letters, l => l.Value.Any(c => c is >= '஀' and <= '௿'));
        Assert.Contains(letters, l => l.FontName!.Contains("NotoSansTamil"));
    }

    [Fact]
    public void LatinText_UsesTheLatinFont_AndMixedTextUsesBoth()
    {
        using var pdf = PdfDocument.Open(Render(TextLayer("Card No", $"{TamilFamily} 333949295789")));
        var fonts = pdf.GetPage(1).Letters.Select(l => l.FontName!).Distinct().ToList();

        Assert.Contains(fonts, f => f.Contains("NotoSansTamil"));
        Assert.Contains(fonts, f => f.Contains("NotoSans") && !f.Contains("Tamil"));
        Assert.Contains("333949295789", pdf.GetPage(1).Text);
    }

    [Fact]
    public void BoldUsesTheBoldFaces()
    {
        using var regular = PdfDocument.Open(Render(TextLayer("K", "Hello")));
        using var bold = PdfDocument.Open(Render(TextLayer("K", "Hello", bold: true)));

        Assert.DoesNotContain(regular.GetPage(1).Letters, l => l.FontName!.Contains("Bold"));
        Assert.Contains(bold.GetPage(1).Letters, l => l.FontName!.Contains("Bold"));
    }

    [Fact]
    public void LongTamilText_WrapsWithinItsWidth()
    {
        var sentence = string.Join(" ", Enumerable.Repeat(TamilFamily, 6));
        var narrow = TextLayer("", sentence, widthMm: 25);
        narrow.Sources[0].Key = "";

        using var pdf = PdfDocument.Open(Render(narrow));
        var letters = pdf.GetPage(1).Letters;
        var lineCount = letters.Select(l => Math.Round(l.StartBaseLine.Y, 0)).Distinct().Count();
        var rightEdge = letters.Max(l => l.EndBaseLine.X);

        Assert.True(lineCount >= 3, $"expected the sentence to wrap onto several lines, got {lineCount}");
        // Wrapped at the layer's 25 mm width (a single long word could overflow slightly).
        Assert.True(rightEdge < (5 + 25) * MmToPt + 12, $"text ran past its width: right edge {rightEdge}");
    }

    // ---- a combined field with a key but no value still prints its key ----

    private static LayerGroupDto Combined(bool bullets, double? keyWidth, params LayerSourceItemDto[] sources) => new()
    {
        IsList = true, BulletList = bullets, KeyWidthMm = keyWidth, XMm = 5, YMm = 5, WidthMm = 70, FontSizePt = 10,
        Sources = sources.ToList(),
    };

    [Fact]
    public void CombinedField_WithAKeyAndNoValue_PrintsItsKey()
    {
        var group = Combined(false, null,
            new LayerSourceItemDto { Key = "Heading", Value = "", Separator = "space" },
            new LayerSourceItemDto { Value = "Body" });

        using var pdf = PdfDocument.Open(Render(group));
        var text = pdf.GetPage(1).Text;

        Assert.Contains("Heading:", text);
        Assert.Contains("Body", text);
    }

    [Fact]
    public void CombinedField_WithNeitherKeyNorValue_PrintsNothing()
    {
        var group = Combined(false, null,
            new LayerSourceItemDto { Value = "First", Separator = "dash" },
            new LayerSourceItemDto { Key = "", Value = "" },
            new LayerSourceItemDto { Value = "Last" });

        using var pdf = PdfDocument.Open(Render(group));

        // No stray separators from the empty field in the middle.
        Assert.Contains("First - Last", pdf.GetPage(1).Text.Replace("\n", " "));
    }

    [Fact]
    public void AlignedCombinedRow_WithAKeyAndNoValue_StillPrintsItsKeyAndSeparator()
    {
        var group = Combined(true, 20,
            new LayerSourceItemDto { Key = "Address", Value = "" },
            new LayerSourceItemDto { Key = "City", Value = "Pune" });

        using var pdf = PdfDocument.Open(Render(group));
        var words = pdf.GetPage(1).GetWords().Select(w => w.Text).ToList();

        Assert.Contains("Address", words);
        Assert.Contains("City", words);
        Assert.Contains("Pune", words);
    }
}
