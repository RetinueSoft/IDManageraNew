using IDManager.Api.Domain.Enums;
using IDManager.Api.Dtos;
using UglyToad.PdfPig;
using UglyToad.PdfPig.Content;

namespace IDManager.Api.Persistence.Services;

// Extracts key/value text pairs and embedded images from a source PDF (e.g. a member's
// certificate) so they can be matched against a template's group definitions.
//
// NOTE: this is a generic row/column heuristic (group words into rows by baseline,
// split into key/value cells by horizontal gap). The predecessor app layered
// script-specific Unicode reordering fixes on top of this for one particular
// language/document layout - that kind of fixup is document-specific and deliberately
// left out of this skeleton; add it back here if a specific source PDF needs it.
public class PdfExtractionService : IPdfExtractionService
{
    public List<ExtractedFieldDto> ExtractFields(Stream pdfStream)
    {
        var result = new List<ExtractedFieldDto>();
        result.AddRange(ExtractText(pdfStream).Select(kv => new ExtractedFieldDto
        {
            Key = kv.Key,
            Value = kv.Value,
            Type = LayerFieldType.Text
        }));

        pdfStream.Position = 0;
        result.AddRange(ExtractImages(pdfStream).Select(kv => new ExtractedFieldDto
        {
            Key = kv.Key,
            Value = kv.Value,
            Type = LayerFieldType.Image
        }));

        return result;
    }

    private static Dictionary<string, string> ExtractText(Stream pdfStream)
    {
        var dict = new Dictionary<string, string>();
        using var pdf = PdfDocument.Open(pdfStream);

        foreach (var page in pdf.GetPages())
        {
            var words = page.GetWords();
            var sortedWords = words.OrderByDescending(w => w.BoundingBox.Bottom).ToList();
            var rows = new List<List<Word>>();
            const double tolerance = 4;

            foreach (var word in sortedWords)
            {
                var row = rows.FirstOrDefault(r => Math.Abs(r[0].BoundingBox.Bottom - word.BoundingBox.Bottom) <= tolerance);
                if (row == null)
                    rows.Add(new List<Word> { word });
                else
                    row.Add(word);
            }

            foreach (var row in rows)
            {
                var ordered = row.OrderBy(w => w.BoundingBox.Left).ToList();
                var cells = new List<string>();
                var current = ordered[0].Text;

                for (var i = 1; i < ordered.Count; i++)
                {
                    var prev = ordered[i - 1];
                    var curr = ordered[i];
                    var gap = curr.BoundingBox.Left - prev.BoundingBox.Right;

                    if (gap > 5)
                    {
                        cells.Add(current.Trim());
                        if (gap > 150)
                            cells.Add("");
                        current = curr.Text;
                    }
                    else
                    {
                        current += " " + curr.Text;
                    }
                }
                cells.Add(current.Trim());

                for (var i = 0; i + 1 < cells.Count; i += 2)
                    dict[cells[i]] = cells[i + 1];
            }
        }

        return dict;
    }

    private static Dictionary<string, string> ExtractImages(Stream pdfStream)
    {
        var dict = new Dictionary<string, string>();
        using var pdf = PdfDocument.Open(pdfStream);

        var pageIndex = 1;
        foreach (var page in pdf.GetPages())
        {
            var imageIndex = 1;
            foreach (var rawImage in page.GetImages())
            {
                var raw = rawImage.RawBytes.ToArray();
                var isJpeg = raw.Length >= 3 && raw[0] == 0xFF && raw[1] == 0xD8 && raw[2] == 0xFF;
                var isPng = raw.Length >= 8 && raw[0] == 0x89 && raw[1] == 0x50 && raw[2] == 0x4E && raw[3] == 0x47;

                byte[]? bytes;
                if (isJpeg || isPng)
                    bytes = raw;
                else if (rawImage.TryGetPng(out var pngBytes))
                    bytes = pngBytes;
                else
                    continue;

                var key = $"image_p{pageIndex}_{imageIndex}";
                dict[key] = Convert.ToBase64String(bytes);
                imageIndex++;
            }
            pageIndex++;
        }

        return dict;
    }
}
