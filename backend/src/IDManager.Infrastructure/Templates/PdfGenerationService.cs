using System.Text;
using IDManager.Domain.Dtos;
using IDManager.Domain.Enums;
using SkiaSharp;
using SkiaSharp.HarfBuzz;

namespace IDManager.Infrastructure.Templates;

/// Renders the card as a print-ready PDF at the template's exact physical size (true vector
/// text and images, not a screenshot).
///
/// Text is shaped with HarfBuzz using embedded Noto fonts, so Tamil (vowel signs, ligatures)
/// prints correctly. That is the reason this uses SkiaSharp rather than a PDF library that
/// only places glyphs one by one. Layout - wrapping, the aligned key column, combined text,
/// line gap - is done here, in points with the origin at the top-left like the designer.
public class PdfGenerationService
{
    // 1 mm = 2.8346456693 PDF points (72 points per inch, 25.4 mm per inch).
    private const double MmToPt = 72.0 / 25.4;

    // The separator column of an aligned list, as a fraction of the font size. Must match the
    // designer's CombinedLayerText.separatorWidthFactor.
    private const double SeparatorWidthFactor = 0.6;

    // Normal line height as a multiple of the font size. Must match the designer's
    // CombinedLayerText.lineHeightFactor.
    private const double LineHeightFactor = 1.2;

    public byte[] GenerateCardPdf(
        byte[] frontImage,
        byte[] backImage,
        double cardWidthMm,
        double cardHeightMm,
        List<TemplateLayerDto> layers)
    {
        // A PDF stores its page size in whole points, so the page is the card size rounded to
        // the nearest point (under 0.2 mm off). The background is drawn to that page size so
        // no white sliver is left at the edge; layer positions still use exact millimeters.
        var widthPt = MathF.Round((float)(cardWidthMm * MmToPt));
        var heightPt = MathF.Round((float)(cardHeightMm * MmToPt));

        using var stream = new SKDynamicMemoryWStream();
        using (var document = SKDocument.CreatePdf(stream))
        using (var renderer = new CardSideRenderer())
        {
            var sides = new[] { (Side: CardSide.Front, Background: frontImage), (Side: CardSide.Back, Background: backImage) };
            foreach (var (side, background) in sides)
            {
                var canvas = document.BeginPage(widthPt, heightPt);
                renderer.Draw(canvas, widthPt, heightPt, background, layers.FirstOrDefault(l => l.Side == side));
                document.EndPage();
            }

            document.Close();
        }

        using var data = stream.CopyToData();
        return data.ToArray();
    }

    /// Draws one side of the card onto a canvas measured in points, origin top-left. Kept
    /// separate from the PDF plumbing so it can also be drawn onto a bitmap for inspection.
    internal sealed class CardSideRenderer : IDisposable
    {
        private readonly Dictionary<SKTypeface, SKShaper> _shapers = new();
        private readonly Dictionary<(bool Tamil, bool Bold, float Size), SKPaint> _paints = new();

        public void Dispose()
        {
            foreach (var shaper in _shapers.Values) shaper.Dispose();
            foreach (var paint in _paints.Values) paint.Dispose();
        }

        public void Draw(SKCanvas canvas, float widthPt, float heightPt, byte[] background, TemplateLayerDto? layer)
        {
            DrawImage(canvas, background, 0, 0, widthPt, heightPt);
            if (layer is null) return;

            foreach (var group in layer.Groups) DrawGroup(canvas, group);
        }

        // ------------------------------------------------------------------ layers

        private void DrawGroup(SKCanvas canvas, LayerGroupDto group)
        {
            var x = (float)(group.XMm * MmToPt);
            var top = (float)(group.YMm * MmToPt);
            var totalWidth = (float)((group.WidthMm ?? 30) * MmToPt);
            var size = (float)group.FontSizePt;

            if (group.IsList && group.Sources.All(s => s.Type == LayerFieldType.Text))
            {
                var style = new TextStyle(size, group.Bold, CombinedLeadingPt(group));
                if (group.KeyWidthMm is > 0) DrawAlignedRows(canvas, group, style, x, top, totalWidth);
                else DrawBlock(canvas, CombinedText(group), x, top, totalWidth, style);
                return;
            }

            var y = top;
            foreach (var source in group.Sources)
            {
                if (source.Type == LayerFieldType.Text)
                {
                    var style = new TextStyle(size, group.Bold, (float)(size * LineHeightFactor));
                    var key = source.Key ?? "";
                    var separator = group.UseDashSeparator ? "-" : ":";
                    float height;

                    if (string.IsNullOrEmpty(key))
                    {
                        height = DrawBlock(canvas, source.Value ?? "", x, y, totalWidth, style);
                    }
                    else if (group.KeyWidthMm is null or <= 0)
                    {
                        // No key width: separator and value follow immediately after the key.
                        height = DrawBlock(canvas, $"{key}{separator} {source.Value ?? ""}", x, y, totalWidth, style);
                    }
                    else
                    {
                        // Key width set: the separator starts at layer x + key width, then the value.
                        height = DrawKeyRow(canvas, group, style, x, y, totalWidth, key, separator, source.Value ?? "");
                    }

                    y += Math.Max((float)(group.LineHeightMm * MmToPt), height);
                }
                else if (source.Type == LayerFieldType.Image && !string.IsNullOrEmpty(source.Value))
                {
                    var heightPt = (float)((group.HeightMm ?? 20) * MmToPt);
                    var widthPt = (float)((group.WidthMm ?? 20) * MmToPt);
                    byte[] bytes;
                    try { bytes = Convert.FromBase64String(source.Value); }
                    catch (FormatException) { continue; }

                    // Stretched to exactly the layer's width x height (not fit-with-aspect-ratio).
                    DrawImage(canvas, bytes, x, y, widthPt, heightPt);
                    y += heightPt + 2;
                }
            }
        }

        /// One row: the key, the separator, then the value, in three columns so the separators
        /// and values line up. Returns the row's height.
        private float DrawKeyRow(
            SKCanvas canvas, LayerGroupDto group, TextStyle style, float x, float top, float totalWidth,
            string key, string separator, string value)
        {
            var keyWidth = (float)(group.KeyWidthMm!.Value * MmToPt);
            var separatorWidth = (float)(group.FontSizePt * SeparatorWidthFactor);
            var valueWidth = (float)((group.ValueWidthMm ?? 0) * MmToPt);
            if (valueWidth <= 0) valueWidth = Math.Max(totalWidth - keyWidth - separatorWidth, 10f);

            var keyHeight = DrawBlock(canvas, key, x, top, keyWidth, style);
            var separatorHeight = DrawBlock(canvas, separator, x + keyWidth, top, separatorWidth, style);
            var valueHeight = DrawBlock(canvas, value, x + keyWidth + separatorWidth, top, valueWidth, style);
            return Math.Max(keyHeight, Math.Max(separatorHeight, valueHeight));
        }

        /// A combined group with a key width: one row per field, the keys sharing one column
        /// KeyWidthMm wide so the separators and values line up (with a bullet before the key
        /// when BulletList is on).
        private void DrawAlignedRows(SKCanvas canvas, LayerGroupDto group, TextStyle style, float x, float top, float totalWidth)
        {
            var separator = group.UseDashSeparator ? "-" : ":";
            var bullet = group.BulletList ? "• " : "";

            var y = top;
            foreach (var row in BulletRows(group))
            {
                if (row.IsBlank) y += style.LeadingPt;
                else if (row.Key.Length == 0) y += DrawBlock(canvas, $"{bullet}{row.Value}", x, y, totalWidth, style);
                else y += DrawKeyRow(canvas, group, style, x, y, totalWidth, $"{bullet}{row.Key}", separator, row.Value);
            }
        }

        // ------------------------------------------------------------------ images

        private static void DrawImage(SKCanvas canvas, byte[] bytes, float x, float y, float width, float height)
        {
            using var data = SKData.CreateCopy(bytes);
            using var image = SKImage.FromEncodedData(data);
            if (image is null) return; // not a decodable image: leave the space empty

            canvas.DrawImage(image, new SKRect(x, y, x + width, y + height));
        }

        // ------------------------------------------------------------------ text

        private readonly record struct TextStyle(float SizePt, bool Bold, float LeadingPt);

        /// Wraps [text] to [width] and draws it with its top-left at ([x], [top]); '\n' starts a
        /// new line. Returns the block's height.
        private float DrawBlock(SKCanvas canvas, string text, float x, float top, float width, TextStyle style)
        {
            var lines = Wrap(text, width, style);
            var baselineOffset = BaselineOffset(style);
            for (var i = 0; i < lines.Count; i++)
            {
                DrawLine(canvas, lines[i], x, top + i * style.LeadingPt + baselineOffset, style);
            }

            return lines.Count * style.LeadingPt;
        }

        /// Where the baseline sits in a line box of height [LeadingPt]: the glyph box centred in
        /// it, the same as the designer's line-height rendering.
        private float BaselineOffset(TextStyle style)
        {
            var metrics = PaintFor(tamil: false, style).FontMetrics;
            var ascent = -metrics.Ascent;
            var descent = metrics.Descent;
            return (style.LeadingPt - (ascent + descent)) / 2 + ascent;
        }

        private List<string> Wrap(string text, float width, TextStyle style)
        {
            var lines = new List<string>();
            foreach (var paragraph in text.Replace("\r\n", "\n").Split('\n'))
            {
                if (paragraph.Length == 0)
                {
                    lines.Add("");
                    continue;
                }

                var line = "";
                foreach (var word in paragraph.Split(' '))
                {
                    var candidate = line.Length == 0 ? word : line + " " + word;
                    if (line.Length > 0 && Measure(candidate, style) > width)
                    {
                        lines.Add(line);
                        line = word;
                    }
                    else
                    {
                        line = candidate;
                    }
                }

                lines.Add(line);
            }

            return lines;
        }

        private float Measure(string text, TextStyle style)
        {
            var total = 0f;
            foreach (var (segment, tamil) in Runs(text))
            {
                var paint = PaintFor(tamil, style);
                total += ShaperFor(paint.Typeface).Shape(segment, paint).Width;
            }

            return total;
        }

        private void DrawLine(SKCanvas canvas, string text, float x, float baselineY, TextStyle style)
        {
            foreach (var (segment, tamil) in Runs(text))
            {
                var paint = PaintFor(tamil, style);
                var shaper = ShaperFor(paint.Typeface);
                canvas.DrawShapedText(shaper, segment, x, baselineY, paint);
                x += shaper.Shape(segment, paint).Width;
            }
        }

        /// Splits text into runs of Tamil and of everything else, so each is shaped with the
        /// font that has its glyphs.
        private static IEnumerable<(string Text, bool Tamil)> Runs(string text)
        {
            var start = 0;
            var current = false;
            for (var i = 0; i < text.Length; i++)
            {
                var tamil = IsTamil(text[i]);
                if (i > start && tamil != current)
                {
                    yield return (text[start..i], current);
                    start = i;
                }

                current = tamil;
            }

            if (start < text.Length) yield return (text[start..], current);
        }

        // The Tamil block, plus the zero-width joiners that can appear inside Tamil words.
        private static bool IsTamil(char c) => c is >= '஀' and <= '௿' or '‌' or '‍';

        private SKPaint PaintFor(bool tamil, TextStyle style)
        {
            var key = (tamil, style.Bold, style.SizePt);
            if (!_paints.TryGetValue(key, out var paint))
            {
                paint = new SKPaint
                {
                    Typeface = CardFonts.Get(tamil, style.Bold),
                    TextSize = style.SizePt,
                    IsAntialias = true,
                    Color = SKColors.Black,
                };
                _paints[key] = paint;
            }

            return paint;
        }

        private SKShaper ShaperFor(SKTypeface typeface)
        {
            if (!_shapers.TryGetValue(typeface, out var shaper))
            {
                shaper = new SKShaper(typeface);
                _shapers[typeface] = shaper;
            }

            return shaper;
        }
    }

    // ------------------------------------------------------------------ text content

    /// Line pitch of a combined group: one normal line height plus its common line gap.
    private static float CombinedLeadingPt(LayerGroupDto group) =>
        (float)(group.FontSizePt * LineHeightFactor + group.LineGapMm * MmToPt);

    /// Each source as "key: value" (just the value when its key is empty), skipping sources
    /// with no value. Each source is followed by its own separator (comma unless set) before
    /// the next; an empty-line entry turns that gap into a blank line; with BulletList every
    /// field gets a bullet and its own line. Must match LayerGroupText.combinedText in the
    /// designer.
    private static string CombinedText(LayerGroupDto group)
    {
        var keyValueSeparator = group.UseDashSeparator ? "-" : ":";

        var result = new StringBuilder();
        var wroteAny = false;
        var pendingJoin = "";
        var emptyLines = 0;

        foreach (var source in group.Sources)
        {
            if (source.EmptyLine)
            {
                emptyLines++;
                continue;
            }
            if (string.IsNullOrWhiteSpace(source.Value)) continue;

            if (wroteAny)
            {
                result.Append(emptyLines > 0 ? new string('\n', emptyLines + 1) : (group.BulletList ? "\n" : pendingJoin));
            }
            else if (emptyLines > 0)
            {
                result.Append(new string('\n', emptyLines));
            }

            if (group.BulletList) result.Append("• ");
            result.Append(string.IsNullOrWhiteSpace(source.Key)
                ? source.Value.Trim()
                : $"{source.Key.Trim()}{keyValueSeparator} {source.Value.Trim()}");

            pendingJoin = JoinText(source.Separator);
            wroteAny = true;
            emptyLines = 0;
        }

        return result.ToString();
    }

    private static string JoinText(string? name) => name switch
    {
        "dash" => " - ",
        "space" => " ",
        "newline" => "\n",
        _ => ", ",
    };

    private readonly record struct BulletRow(bool IsBlank, string Key, string Value);

    /// One row per source with a value, plus one blank row per empty-line entry (trailing
    /// blanks dropped). Must match LayerGroupText.bulletRows in the designer.
    private static List<BulletRow> BulletRows(LayerGroupDto group)
    {
        var rows = new List<BulletRow>();
        foreach (var source in group.Sources)
        {
            if (source.EmptyLine)
            {
                rows.Add(new BulletRow(true, "", ""));
                continue;
            }
            if (string.IsNullOrWhiteSpace(source.Value)) continue;
            rows.Add(new BulletRow(false, (source.Key ?? "").Trim(), source.Value.Trim()));
        }

        while (rows.Count > 0 && rows[^1].IsBlank) rows.RemoveAt(rows.Count - 1);
        return rows;
    }
}

/// The fonts, loaded once from the assembly's embedded resources (Noto Sans and Noto Sans
/// Tamil, SIL Open Font License - see Fonts/README.md).
internal static class CardFonts
{
    private static readonly Lazy<SKTypeface> TamilRegular = new(() => Load("NotoSansTamil-Regular.ttf"));
    private static readonly Lazy<SKTypeface> TamilBold = new(() => Load("NotoSansTamil-Bold.ttf"));
    private static readonly Lazy<SKTypeface> LatinRegular = new(() => Load("NotoSans-Regular.ttf"));
    private static readonly Lazy<SKTypeface> LatinBold = new(() => Load("NotoSans-Bold.ttf"));

    public static SKTypeface Get(bool tamil, bool bold) => (tamil, bold) switch
    {
        (true, true) => TamilBold.Value,
        (true, false) => TamilRegular.Value,
        (false, true) => LatinBold.Value,
        (false, false) => LatinRegular.Value,
    };

    private static SKTypeface Load(string file)
    {
        using var stream = typeof(CardFonts).Assembly.GetManifestResourceStream("Fonts." + file)
            ?? throw new InvalidOperationException($"Embedded font {file} is missing.");
        using var data = SKData.Create(stream);
        return SKTypeface.FromData(data) ?? throw new InvalidOperationException($"Font {file} could not be loaded.");
    }
}
