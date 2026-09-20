import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/templates/domain/date_formatter.dart';

/// A layer can name a date format (e.g. dd/MM/yyyy): a value that is a date is printed in that
/// format, anything else is left alone. The same cases are tested on the backend
/// (DateValueFormatterTests.cs): the designer and the printed PDF must format dates identically.
void main() {
  group('reformats a date value', () {
    const cases = <(String, String, String)>[
      ('01-Jan-1968', 'dd/MM/yyyy', '01/01/1968'), // the case from the member PDF
      ('26-Jul-1972', 'dd/MM/yyyy', '26/07/1972'),
      ('01/01/1968', 'dd-MMM-yyyy', '01-Jan-1968'),
      ('31-12-2020', 'yyyy-MM-dd', '2020-12-31'),
      ('1968-01-31', 'dd/MM/yyyy', '31/01/1968'), // year first
      ('09 December 2023', 'dd/MM/yyyy', '09/12/2023'), // full month name
      ('Jan 5, 2020', 'dd/MM/yyyy', '05/01/2020'), // month first with a comma
      ('5.3.2021', 'dd/MM/yyyy', '05/03/2021'), // dots, no zero padding
      (' 01-Jan-1968 ', 'dd/MM/yyyy', '01/01/1968'), // surrounding spaces
      ('01-JAN-1968', 'dd/MM/yyyy', '01/01/1968'), // any case
      ('01-january-1968', 'dd/MM/yyyy', '01/01/1968'),
    ];
    for (final (value, format, expected) in cases) {
      test('"$value" as $format is "$expected"', () {
        expect(reformatDate(value, format), expected);
      });
    }
  });

  group('supports the usual format tokens', () {
    const cases = <(String, String)>[
      ('dd/MM/yyyy', '07/03/2024'),
      ('d/M/yyyy', '7/3/2024'),
      ('dd-MMM-yyyy', '07-Mar-2024'),
      ('dd MMMM yyyy', '07 March 2024'),
      ('d MMMM yyyy', '7 March 2024'),
      ('MM/dd/yyyy', '03/07/2024'),
      ('yyyy-MM-dd', '2024-03-07'),
      ('dd MMM yy', '07 Mar 24'),
      ('MMMM d, yyyy', 'March 7, 2024'),
    ];
    for (final (format, expected) in cases) {
      test('$format gives $expected', () {
        expect(reformatDate('07-Mar-2024', format), expected);
      });
    }
  });

  group('a value that is not a date is left alone', () {
    const values = [
      '614001', // a postcode
      '9876543210', // a phone number
      '01-Jan-1968 10:30', // has a time: not a plain date
      '09 December 2023 | 03:42:37 PM',
      '31-Feb-2020', // not a real date
      '32/01/2020',
      'hello',
      '',
      '26-Jul-1972 extra',
      'Foo 5, 2020', // not a month
    ];
    for (final value in values) {
      test('"$value"', () {
        expect(reformatDate(value, 'dd/MM/yyyy'), value);
      });
    }
  });

  group('no usable format leaves the value alone', () {
    for (final format in <String?>[null, '', '   ', 'hello', '/ - ']) {
      test('format ${format == null ? 'null' : '"$format"'}', () {
        expect(reformatDate('01-Jan-1968', format), '01-Jan-1968');
      });
    }
  });

  test('a date already in the format stays the same', () {
    expect(reformatDate('01/01/1968', 'dd/MM/yyyy'), '01/01/1968');
  });

  test('a leap day is accepted and an impossible one is not', () {
    expect(reformatDate('29-Feb-2020', 'dd/MM/yyyy'), '29/02/2020');
    expect(reformatDate('29-Feb-2021', 'dd/MM/yyyy'), '29-Feb-2021');
  });

  test('exampleForFormat shows a fixed sample date in the chosen format', () {
    expect(exampleForFormat('dd/MM/yyyy'), '07/03/2024');
    expect(exampleForFormat('dd MMMM yyyy'), '07 March 2024');
    expect(exampleForFormat('hello'), isNull); // not a usable format
    expect(exampleForFormat(''), isNull);
  });
}
