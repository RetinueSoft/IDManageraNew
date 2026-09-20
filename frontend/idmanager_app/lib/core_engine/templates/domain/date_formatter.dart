// Prints a date value in the format a layer names, e.g. "01-Jan-1968" as "01/01/1968" for
// dd/MM/yyyy. A value that is not a plain date (a postcode, a phone number, a date with a time,
// an impossible date like 31-Feb) is returned exactly as it was. The backend has the same
// function (DateValueFormatter.cs) and the same tests: the designer and the printed PDF must
// format dates identically.
//
// Recognised inputs, day first (so 05/03/2021 is 5 March): dd-MM-yyyy (separators - / . or
// space), yyyy-MM-dd, dd-MMM-yyyy and dd MMMM yyyy (English month names, any case), and
// "MMM d, yyyy".
//
// Format tokens: yyyy, yy, MMMM, MMM, MM, M, dd, d. Everything else is printed as typed.

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

// Longest first, so "MMMM" is read before "MMM", "MM" and "M".
const _tokens = ['yyyy', 'MMMM', 'MMM', 'MM', 'dd', 'yy', 'M', 'd'];

final _dayMonthYearNumeric = RegExp(r'^([0-9]{1,2})[-/. ]([0-9]{1,2})[-/. ]([0-9]{4})$');
final _yearMonthDayNumeric = RegExp(r'^([0-9]{4})[-/.]([0-9]{1,2})[-/.]([0-9]{1,2})$');
final _dayMonthNameYear = RegExp(r'^([0-9]{1,2})[-/. ]+([A-Za-z]+)[-/. ]+([0-9]{4})$');
final _monthNameDayYear = RegExp(r'^([A-Za-z]+)\.? +([0-9]{1,2}),? +([0-9]{4})$');

/// [value] as a date in [format], or [value] itself when it is not a date or [format] has no date
/// parts.
String reformatDate(String value, String? format) {
  if (value.trim().isEmpty || !isUsableDateFormat(format)) return value;

  final date = _parse(value.trim());
  return date == null ? value : _format(date.$1, date.$2, date.$3, format!);
}

/// A fixed sample date (7 March 2024) in [format], or null if [format] has no date parts.
String? exampleForFormat(String? format) => isUsableDateFormat(format) ? _format(2024, 3, 7, format!) : null;

bool isUsableDateFormat(String? format) =>
    format != null && format.trim().isNotEmpty && _tokens.any(format.contains);

(int, int, int)? _parse(String text) {
  var m = _dayMonthYearNumeric.firstMatch(text);
  if (m != null) return _valid(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!));

  m = _yearMonthDayNumeric.firstMatch(text);
  if (m != null) return _valid(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));

  m = _dayMonthNameYear.firstMatch(text);
  if (m != null) {
    final month = _monthNumber(m[2]!);
    if (month != null) return _valid(int.parse(m[3]!), month, int.parse(m[1]!));
  }

  m = _monthNameDayYear.firstMatch(text);
  if (m != null) {
    final month = _monthNumber(m[1]!);
    if (month != null) return _valid(int.parse(m[3]!), month, int.parse(m[2]!));
  }

  return null;
}

(int, int, int)? _valid(int year, int month, int day) {
  if (year < 1 || month < 1 || month > 12 || day < 1) return null;
  final daysInMonth = DateTime(year, month + 1, 0).day;
  return day <= daysInMonth ? (year, month, day) : null;
}

/// 1-12 for a full English month name or its 3-letter abbreviation, any case; else null.
int? _monthNumber(String name) {
  final lower = name.toLowerCase();
  for (var i = 0; i < _months.length; i++) {
    final full = _months[i].toLowerCase();
    if (lower == full || lower == full.substring(0, 3)) return i + 1;
  }
  return null;
}

String _pad(int n, int width) => n.toString().padLeft(width, '0');

String _format(int year, int month, int day, String format) {
  final result = StringBuffer();
  var i = 0;
  while (i < format.length) {
    String? token;
    for (final t in _tokens) {
      if (format.startsWith(t, i)) {
        token = t;
        break;
      }
    }
    if (token == null) {
      result.write(format[i]);
      i++;
      continue;
    }

    result.write(switch (token) {
      'yyyy' => _pad(year, 4),
      'yy' => _pad(year % 100, 2),
      'MMMM' => _months[month - 1],
      'MMM' => _months[month - 1].substring(0, 3),
      'MM' => _pad(month, 2),
      'M' => month.toString(),
      'dd' => _pad(day, 2),
      _ => day.toString(), // 'd'
    });
    i += token.length;
  }
  return result.toString();
}
