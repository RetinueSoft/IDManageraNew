using IDManager.Api.Dtos;

namespace IDManager.Api.Persistence.Services;

public interface IPdfExtractionService
{
    List<ExtractedFieldDto> ExtractFields(Stream pdfStream);
}
