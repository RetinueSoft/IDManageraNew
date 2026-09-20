using IDManager.Infrastructure.Cards;
using SkiaSharp;
using Xunit;
using ZXing;
using ZXing.QrCode.Internal;

namespace IDManager.Tests.Cards;

public class QrCodeRegeneratorTests
{
    private const string Content = "https://example.com/member/1234567890";

    /// A QR for [text] drawn as an image, [scale] pixels per module, with [quiet] modules of white round it.
    private static byte[] MakeQr(string text, int scale = 8, int quiet = 4, ErrorCorrectionLevel? level = null)
    {
        var hints = new Dictionary<EncodeHintType, object>();
        if (text.Any(c => c > 0xFF)) hints[EncodeHintType.CHARACTER_SET] = "UTF-8";
        var matrix = Encoder.encode(text, level ?? ErrorCorrectionLevel.M, hints).Matrix;
        var size = (matrix.Width + 2 * quiet) * scale;
        using var bitmap = new SKBitmap(size, size);
        using (var canvas = new SKCanvas(bitmap))
        {
            canvas.Clear(SKColors.White);
            using var black = new SKPaint { Color = SKColors.Black };
            for (var y = 0; y < matrix.Height; y++)
            {
                for (var x = 0; x < matrix.Width; x++)
                {
                    if (matrix[x, y] == 1) canvas.DrawRect((x + quiet) * scale, (y + quiet) * scale, scale, scale, black);
                }
            }
        }
        return Png(bitmap);
    }

    private static byte[] Png(SKBitmap bitmap)
    {
        using var image = SKImage.FromBitmap(bitmap);
        return image.Encode(SKEncodedImageFormat.Png, 100).ToArray();
    }

    private static SKBitmap Load(byte[] png) => SKBitmap.Decode(png);

    private static byte[] Resize(byte[] png, int width, int height, SKFilterQuality quality = SKFilterQuality.High)
    {
        using var source = Load(png);
        using var target = new SKBitmap(width, height);
        using (var canvas = new SKCanvas(target))
        {
            canvas.Clear(SKColors.White);
            using var paint = new SKPaint { FilterQuality = quality, IsAntialias = true };
            canvas.DrawBitmap(source, new SKRect(0, 0, width, height), paint);
        }
        return Png(target);
    }

    private static byte[] Blur(byte[] png, float sigma)
    {
        using var source = Load(png);
        using var target = new SKBitmap(source.Width, source.Height);
        using (var canvas = new SKCanvas(target))
        {
            using var paint = new SKPaint { ImageFilter = SKImageFilter.CreateBlur(sigma, sigma) };
            canvas.Clear(SKColors.White);
            canvas.DrawBitmap(source, 0, 0, paint);
        }
        return Png(target);
    }

    /// What the regenerated PNG reads back as.
    private static string? ReadBack(byte[] regenerated) => QrCodeRegenerator.Read(regenerated)?.Text;

    [Fact]
    public void ACleanQr_IsRegeneratedWithTheSameContent()
    {
        var original = MakeQr(Content);

        var regenerated = QrCodeRegenerator.Regenerate(original, out var content);

        Assert.NotNull(regenerated);
        Assert.Equal(Content, content);
        Assert.Equal(Content, ReadBack(regenerated!));
        // It is our own drawing, not the upload passed through.
        Assert.NotEqual(original, regenerated);
    }

    [Fact]
    public void TheRegeneratedQr_IsSquare_LargeAndSharp()
    {
        var regenerated = QrCodeRegenerator.Regenerate(MakeQr(Content))!;
        using var bitmap = Load(regenerated);

        Assert.Equal(bitmap.Width, bitmap.Height);
        Assert.InRange(bitmap.Width, 1024, 1300);
        // Only pure black and white - no anti-aliased grey edges.
        var pixels = new HashSet<uint>();
        for (var y = 0; y < bitmap.Height; y += 7)
        {
            for (var x = 0; x < bitmap.Width; x += 7) pixels.Add((uint)bitmap.GetPixel(x, y));
        }
        Assert.All(pixels, p => Assert.Contains(p, new uint[] { 0xFF000000, 0xFFFFFFFF }));
        // The corner is the quiet zone: white.
        Assert.Equal(SKColors.White, bitmap.GetPixel(2, 2));
    }

    [Fact]
    public void ATightlyCroppedQr_WithNoWhiteBorder_IsRead()
    {
        var tight = MakeQr(Content, scale: 8, quiet: 0);

        Assert.Equal(Content, ReadBack(QrCodeRegenerator.Regenerate(tight)!));
    }

    [Fact]
    public void ABlurryQr_IsRead()
    {
        var blurry = Blur(MakeQr(Content, scale: 10), 3f);

        var regenerated = QrCodeRegenerator.Regenerate(blurry);

        Assert.NotNull(regenerated);
        Assert.Equal(Content, ReadBack(regenerated!));
    }

    [Fact]
    public void ALowResolutionQr_IsRead()
    {
        // Squeezed to a tiny thumbnail (about 2 pixels per module) and pulled back up.
        var tiny = Resize(MakeQr(Content, scale: 10), 90, 90);
        var lowRes = Resize(tiny, 360, 360);

        Assert.Equal(Content, ReadBack(QrCodeRegenerator.Regenerate(lowRes)!));
    }

    [Fact]
    public void AStretchedNonSquareQr_IsRead_AndComesBackSquare()
    {
        var stretched = Resize(MakeQr(Content, scale: 8), 600, 420);

        var regenerated = QrCodeRegenerator.Regenerate(stretched);

        Assert.NotNull(regenerated);
        using var bitmap = Load(regenerated!);
        Assert.Equal(bitmap.Width, bitmap.Height);
    }

    [Fact]
    public void AQrWithLotsOfWhiteAround_IsRead()
    {
        var padded = MakeQr(Content, scale: 6, quiet: 30);

        Assert.Equal(Content, ReadBack(QrCodeRegenerator.Regenerate(padded)!));
    }

    [Fact]
    public void ATransparentQr_IsReadOnAWhiteBackground()
    {
        using var source = Load(MakeQr(Content, scale: 8));
        using var transparent = new SKBitmap(new SKImageInfo(source.Width, source.Height, SKColorType.Rgba8888, SKAlphaType.Premul));
        for (var y = 0; y < source.Height; y++)
        {
            for (var x = 0; x < source.Width; x++)
            {
                transparent.SetPixel(x, y, source.GetPixel(x, y) == SKColors.White ? SKColors.Transparent : SKColors.Black);
            }
        }

        Assert.Equal(Content, ReadBack(QrCodeRegenerator.Regenerate(Png(transparent))!));
    }

    [Fact]
    public void TamilText_SurvivesTheRoundTrip()
    {
        const string tamil = "பெயர்: ரவி, முகவரி: 117 கூளமடை";

        var regenerated = QrCodeRegenerator.Regenerate(MakeQr(tamil, scale: 8), out var content);

        Assert.Equal(tamil, content);
        Assert.Equal(tamil, ReadBack(regenerated!));
    }

    [Theory]
    [InlineData("L")]
    [InlineData("H")]
    public void TheErrorCorrectionLevel_IsKept(string levelName)
    {
        var level = levelName == "L" ? ErrorCorrectionLevel.L : ErrorCorrectionLevel.H;

        var read = QrCodeRegenerator.Read(MakeQr(Content, level: level));

        Assert.Equal(level, read!.Value.Level);
    }

    [Fact]
    public void ABlankImage_IsRejected()
    {
        using var bitmap = new SKBitmap(300, 300);
        using (var canvas = new SKCanvas(bitmap)) canvas.Clear(SKColors.White);

        Assert.Null(QrCodeRegenerator.Regenerate(Png(bitmap)));
    }

    [Fact]
    public void APhotoOrNoise_IsRejected()
    {
        using var bitmap = new SKBitmap(300, 300);
        var random = new Random(42);
        for (var y = 0; y < 300; y++)
        {
            for (var x = 0; x < 300; x++)
            {
                bitmap.SetPixel(x, y, new SKColor((byte)random.Next(256), (byte)random.Next(256), (byte)random.Next(256)));
            }
        }

        Assert.Null(QrCodeRegenerator.Regenerate(Png(bitmap)));
    }

    [Fact]
    public void ACroppedQr_MissingACorner_IsRejected()
    {
        // Cut so a finder pattern is lost: this is the "not properly cropped" case that cannot be read.
        using var full = Load(MakeQr(Content, scale: 8, quiet: 0));
        using var cut = new SKBitmap(full.Width / 2, full.Height / 2);
        using (var canvas = new SKCanvas(cut))
        {
            canvas.DrawBitmap(full, new SKRect(full.Width / 2, full.Height / 2, full.Width, full.Height), new SKRect(0, 0, cut.Width, cut.Height));
        }

        Assert.Null(QrCodeRegenerator.Regenerate(Png(cut)));
    }

    [Theory]
    [InlineData(new byte[0])]
    [InlineData(new byte[] { 0xFF, 0x00, 0x01, 0x02 })]
    public void BytesThatAreNotAnImage_AreRejected(byte[] bytes)
    {
        Assert.Null(QrCodeRegenerator.Regenerate(bytes));
    }
}
