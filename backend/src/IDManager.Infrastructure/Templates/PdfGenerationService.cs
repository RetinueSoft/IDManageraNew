using IDManager.Domain.Dtos;
using IDManager.Domain.Enums;
using iText.IO.Image;
using iText.Kernel.Geom;
using iText.Kernel.Pdf;
using iText.Kernel.Pdf.Canvas;
using iText.Layout;
using iText.Layout.Element;

namespace IDManager.Infrastructure.Templates;

public class PdfGenerationService
{
    // 1 mm = 2.8346456693 PDF points (72 points per inch, 25.4 mm per inch).
    private const double MmToPt = 72.0 / 25.4;

    /// Renders the card as true vector content (positioned text + images), sized to
    /// the template's exact physical dimensions - not a rasterized screenshot - so
    /// print output is crisp regardless of the screen resolution the layers were
    /// designed at.
    public byte[] GenerateCardPdf(
        byte[] frontImage,
        byte[] backImage,
        double cardWidthMm,
        double cardHeightMm,
        List<TemplateLayerDto> layers)
    {
        var pageSize = new PageSize((float)(cardWidthMm * MmToPt), (float)(cardHeightMm * MmToPt));

        using var ms = new MemoryStream();
        using (var writer = new PdfWriter(ms))
        using (var pdf = new PdfDocument(writer))
        {
            var document = new Document(pdf, pageSize);
            document.SetMargins(0, 0, 0, 0);

            AddSide(pdf, document, pageSize, frontImage, layers.FirstOrDefault(l => l.Side == CardSide.Front));
            AddSide(pdf, document, pageSize, backImage, layers.FirstOrDefault(l => l.Side == CardSide.Back));

            document.Close();
        }

        return ms.ToArray();
    }

    private static void AddSide(PdfDocument pdf, Document document, PageSize pageSize, byte[] backgroundImage, TemplateLayerDto? layer)
    {
        pdf.AddNewPage(pageSize);
        var page = pdf.GetLastPage();
        var canvas = new PdfCanvas(page);
        var bgImage = ImageDataFactory.Create(backgroundImage);
        canvas.AddImageFittedIntoRectangle(bgImage, new Rectangle(0, 0, pageSize.GetWidth(), pageSize.GetHeight()), false);

        if (layer == null) return;

        foreach (var group in layer.Groups)
        {
            var xPt = (float)(group.XMm * MmToPt);
            // PDF y-axis origin is bottom-left; our layer y is measured from the top.
            var yPt = (float)(pageSize.GetHeight() - group.YMm * MmToPt);
            var currentY = yPt;

            foreach (var source in group.Sources)
            {
                if (source.Type == LayerFieldType.Text)
                {
                    var keyWidthPt = (float)((group.KeyWidthMm ?? 0) * MmToPt);
                    var valueWidthPt = (float)((group.ValueWidthMm ?? (group.WidthMm ?? 30)) * MmToPt);

                    var table = new Table(new[] { keyWidthPt > 0 ? keyWidthPt : 1f, 4f, valueWidthPt })
                        .SetFixedPosition(xPt, currentY - (float)(group.LineHeightMm * MmToPt), keyWidthPt + valueWidthPt + 4);

                    table.AddCell(new Cell().Add(new Paragraph(source.Key ?? "").SetFontSize((float)group.FontSizePt)).SetBorder(iText.Layout.Borders.Border.NO_BORDER));
                    table.AddCell(new Cell().Add(new Paragraph(!string.IsNullOrEmpty(source.Key) ? (group.UseDashSeparator ? "-" : ":") : "").SetFontSize((float)group.FontSizePt)).SetBorder(iText.Layout.Borders.Border.NO_BORDER));
                    table.AddCell(new Cell().Add(new Paragraph(source.Value ?? "").SetFontSize((float)group.FontSizePt)).SetBorder(iText.Layout.Borders.Border.NO_BORDER));

                    document.Add(table);
                    currentY -= (float)(group.LineHeightMm * MmToPt);
                }
                else if (source.Type == LayerFieldType.Image && !string.IsNullOrEmpty(source.Value))
                {
                    var imgBytes = Convert.FromBase64String(source.Value);
                    var imgData = ImageDataFactory.Create(imgBytes);
                    var heightPt = (float)((group.HeightMm ?? 20) * MmToPt);
                    var widthPt = (float)((group.WidthMm ?? 20) * MmToPt);

                    var img = new Image(imgData).ScaleToFit(widthPt, heightPt).SetFixedPosition(xPt, currentY - heightPt);
                    document.Add(img);
                    currentY -= heightPt + 2;
                }
            }
        }
    }
}
