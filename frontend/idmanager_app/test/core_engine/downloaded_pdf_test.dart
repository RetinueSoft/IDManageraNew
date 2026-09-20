import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/cards/domain/downloaded_pdf.dart';

void main() {
  group('pdfNameFromHeaders', () {
    test('uses the X-File-Name header, URL decoded', () {
      expect(pdfNameFromHeaders(fileNameHeader: 'Ravi%20Kumar%20-%201234'), 'Ravi Kumar - 1234');
    });

    test('decodes a Tamil name', () {
      final encoded = Uri.encodeComponent('ரவி குமார் - 117');

      expect(pdfNameFromHeaders(fileNameHeader: encoded), 'ரவி குமார் - 117');
    });

    test('falls back to the Content-Disposition file name, and drops .pdf', () {
      expect(
        pdfNameFromHeaders(contentDisposition: 'attachment; filename="Ravi Kumar.pdf"'),
        'Ravi Kumar',
      );
      expect(pdfNameFromHeaders(contentDisposition: 'attachment; filename=card-5.pdf'), 'card-5');
    });

    test('reads the RFC 5987 form ASP.NET sends for a non-ASCII name', () {
      final header = "attachment; filename=card.pdf; filename*=UTF-8''${Uri.encodeComponent('ரவி.pdf')}";

      expect(pdfNameFromHeaders(contentDisposition: header), 'ரவி');
    });

    test('the X-File-Name header wins over Content-Disposition', () {
      expect(
        pdfNameFromHeaders(fileNameHeader: 'From%20header', contentDisposition: 'attachment; filename="other.pdf"'),
        'From header',
      );
    });

    test('with no usable header the fallback is used', () {
      expect(pdfNameFromHeaders(), 'card');
      expect(pdfNameFromHeaders(fallback: 'card-9'), 'card-9');
      expect(pdfNameFromHeaders(fileNameHeader: '   ', fallback: 'card-9'), 'card-9');
      expect(pdfNameFromHeaders(fileNameHeader: '.pdf', fallback: 'card-9'), 'card-9');
    });

    test('a malformed encoding is used as it is rather than failing', () {
      expect(pdfNameFromHeaders(fileNameHeader: '100%'), '100%');
    });
  });
}
