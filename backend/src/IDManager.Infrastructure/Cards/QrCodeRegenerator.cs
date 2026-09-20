using SkiaSharp;
using ZXing;
using ZXing.Common;
using ZXing.QrCode.Internal;

namespace IDManager.Infrastructure.Cards;

/// Turns whatever QR image a user uploads into a clean one we generate ourselves: the QR is
/// read, and a fresh, sharp, correctly cropped QR with the same content is drawn. A blurry,
/// low-resolution, tilted, tightly cropped or padded upload still ends up as a good QR on the
/// card - and an upload that is not a QR at all is rejected instead of printed.
public static class QrCodeRegenerator
{
    /// Blank modules around the regenerated code (the QR "quiet zone"; the spec asks for 4, two
    /// is enough for phone scanners on a light card and keeps the code larger in its slot).
    public const int QuietZoneModules = 2;

    /// The regenerated PNG is about this many pixels wide, in whole pixels per module so its
    /// edges stay perfectly sharp when the PDF stretches it to the slot.
    private const int TargetPixels = 1024;

    /// Larger uploads are shrunk to this before reading, which is faster and often reads better.
    private const int MaxReadPixels = 1600;

    /// Reads the QR in [imageBytes] and returns a newly generated PNG of it, or null when the
    /// bytes are not an image or no QR code can be read from it.
    public static byte[]? Regenerate(byte[] imageBytes) => Regenerate(imageBytes, out _);

    /// As [Regenerate], also returning the text the QR carries.
    public static byte[]? Regenerate(byte[] imageBytes, out string? content)
    {
        content = null;
        var read = Read(imageBytes);
        if (read is null) return null;

        content = read.Value.Text;
        return Render(read.Value.Text, read.Value.Level);
    }

    /// The text (and error-correction level) of the QR in the image, or null.
    internal static (string Text, ErrorCorrectionLevel Level)? Read(byte[] imageBytes)
    {
        if (imageBytes is null || imageBytes.Length == 0) return null;

        SKBitmap? decoded;
        try { decoded = SKBitmap.Decode(imageBytes); }
        catch { return null; }
        if (decoded is null || decoded.Width < 1 || decoded.Height < 1) return null;

        using (decoded)
        {
            var reader = new BarcodeReaderGeneric
            {
                AutoRotate = true,
                Options = new DecodingOptions
                {
                    TryHarder = true,
                    TryInverted = true,
                    PossibleFormats = [BarcodeFormat.QR_CODE],
                },
            };

            var longest = Math.Max(decoded.Width, decoded.Height);
            var baseScale = longest > MaxReadPixels ? (double)MaxReadPixels / longest : 1.0;

            // A poor upload often fails at its own size but reads at another, or needs white space
            // around it (a tight crop leaves no quiet zone). Try a few sizes, with and without padding.
            foreach (var scale in new[] { 1.0, 0.5, 2.0, 0.25 })
            {
                foreach (var padFraction in new[] { 0.0, 0.15 })
                {
                    var width = (int)Math.Round(decoded.Width * baseScale * scale);
                    var height = (int)Math.Round(decoded.Height * baseScale * scale);
                    if (width < 21 || height < 21 || Math.Max(width, height) > 3200) continue;

                    using var attempt = OnWhite(decoded, width, height, (int)Math.Round(Math.Max(width, height) * padFraction));
                    var source = new RGBLuminanceSource(attempt.Bytes, attempt.Width, attempt.Height, RGBLuminanceSource.BitmapFormat.BGRA32);
                    var result = reader.Decode(source);
                    if (result is not null && !string.IsNullOrEmpty(result.Text))
                    {
                        return (result.Text, LevelOf(result));
                    }
                }
            }
        }
        return null;
    }

    /// The image scaled to [width] x [height] on a white background with [pad] pixels of white all
    /// round (white also stands in for any transparency).
    private static SKBitmap OnWhite(SKBitmap source, int width, int height, int pad)
    {
        var bitmap = new SKBitmap(new SKImageInfo(width + 2 * pad, height + 2 * pad, SKColorType.Bgra8888, SKAlphaType.Premul));
        using var canvas = new SKCanvas(bitmap);
        canvas.Clear(SKColors.White);
        using var paint = new SKPaint { IsAntialias = true, FilterQuality = SKFilterQuality.High };
        canvas.DrawBitmap(source, new SKRect(pad, pad, pad + width, pad + height), paint);
        return bitmap;
    }

    private static ErrorCorrectionLevel LevelOf(Result result)
    {
        if (result.ResultMetadata is not null &&
            result.ResultMetadata.TryGetValue(ResultMetadataType.ERROR_CORRECTION_LEVEL, out var value))
        {
            return value?.ToString() switch
            {
                "L" => ErrorCorrectionLevel.L,
                "Q" => ErrorCorrectionLevel.Q,
                "H" => ErrorCorrectionLevel.H,
                _ => ErrorCorrectionLevel.M,
            };
        }
        return ErrorCorrectionLevel.M;
    }

    /// Draws a QR for [text] as a sharp black-on-white PNG.
    internal static byte[] Render(string text, ErrorCorrectionLevel level)
    {
        var hints = new Dictionary<EncodeHintType, object>();
        // Tamil and other non-Latin text needs UTF-8; plain Latin text keeps ZXing's default.
        if (text.Any(c => c > 0xFF)) hints[EncodeHintType.CHARACTER_SET] = "UTF-8";

        var matrix = Encoder.encode(text, level, hints).Matrix;
        var modules = matrix.Width + 2 * QuietZoneModules;
        var pixelsPerModule = Math.Max(1, (int)Math.Ceiling(TargetPixels / (double)modules));
        var size = modules * pixelsPerModule;

        using var bitmap = new SKBitmap(new SKImageInfo(size, size, SKColorType.Rgba8888, SKAlphaType.Opaque));
        using (var canvas = new SKCanvas(bitmap))
        {
            canvas.Clear(SKColors.White);
            using var black = new SKPaint { Color = SKColors.Black, IsAntialias = false };
            for (var y = 0; y < matrix.Height; y++)
            {
                for (var x = 0; x < matrix.Width; x++)
                {
                    if (matrix[x, y] != 1) continue;
                    var left = (x + QuietZoneModules) * pixelsPerModule;
                    var top = (y + QuietZoneModules) * pixelsPerModule;
                    canvas.DrawRect(left, top, pixelsPerModule, pixelsPerModule, black);
                }
            }
        }

        using var image = SKImage.FromBitmap(bitmap);
        using var data = image.Encode(SKEncodedImageFormat.Png, 100);
        return data.ToArray();
    }
}
