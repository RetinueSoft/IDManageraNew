import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/templates/domain/template_layer.dart';
import 'package:idmanager_app/presentation/shared/widgets/card_text.dart';
import 'package:idmanager_app/presentation/shared/widgets/card_text_layer.dart';

/// The card preview and the designer must show what the backend prints. The PDF places each
/// line in a box of (font size x 1.2 + line gap), with the glyph box (Noto Sans: ascent 1.069,
/// descent 0.293 em) centred in it. These tests check the on-screen layout against that.
const _ascentEm = 1.069;
const _descentEm = 0.293;
const _pxPerMm = 12.0; // the scale the screens use (see TemplateEditorScreen.pxPerMm)

/// Flutter rounds each line's height to a whole pixel, so on-screen measurements are within
/// half a pixel of the exact value (0.04 mm at 12 px/mm).
const _halfPx = 0.6;

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> assets) async {
    final loader = FontLoader(family);
    for (final a in assets) {
      loader.addFont(rootBundle.load(a));
    }
    await loader.load();
  }

  await load('NotoSans', ['assets/fonts/NotoSans-Regular.ttf', 'assets/fonts/NotoSans-Bold.ttf']);
  await load('NotoSansTamil', ['assets/fonts/NotoSansTamil-Regular.ttf', 'assets/fonts/NotoSansTamil-Bold.ttf']);
}

LayerGroup _group({
  List<LayerSourceItem> sources = const [],
  double size = 10,
  double? width = 60,
  double? keyWidth,
  bool isList = false,
  double gapMm = 0,
  double lineHeightMm = 0, // no minimum row height, so a row is exactly its text
  bool bold = false,
}) => LayerGroup(
  id: 'g',
  name: 'g',
  xMm: 0,
  yMm: 0,
  fontSizePt: size,
  widthMm: width,
  keyWidthMm: keyWidth,
  isList: isList,
  lineGapMm: gapMm,
  lineHeightMm: lineHeightMm,
  bold: bold,
  sources: sources,
);

Future<void> _pump(WidgetTester tester, LayerGroup group) => tester.pumpWidget(
  MaterialApp(
    home: Align(
      alignment: Alignment.topLeft,
      child: CardTextLayer(group: group, pxPerMm: _pxPerMm),
    ),
  ),
);

double _baseline(WidgetTester tester, String text) {
  final render = tester.renderObject<RenderParagraph>(find.text(text));
  return render.computeDistanceToActualBaseline(TextBaseline.alphabetic)!;
}

void main() {
  setUpAll(_loadFonts);

  final fontPx = 10 * CardText.pointsToMm * _pxPerMm; // 10 pt at 12 px/mm
  final lineBox = fontPx * 1.2;
  // The backend: baseline = top + (lineBox - glyphBox) / 2 + ascent.
  final expectedBaseline = (lineBox - (_ascentEm + _descentEm) * fontPx) / 2 + _ascentEm * fontPx;

  testWidgets('a line sits in a box of 1.2 x the font size, baseline where the PDF puts it', (tester) async {
    await _pump(tester, _group(sources: const [LayerSourceItem(key: '', value: 'Hello')]));

    expect(tester.getSize(find.text('Hello')).height, closeTo(lineBox, _halfPx));
    expect(_baseline(tester, 'Hello'), closeTo(expectedBaseline, _halfPx));
    // No padding: the text starts at the layer's own top-left.
    expect(tester.getTopLeft(find.text('Hello')), Offset.zero);
  });

  testWidgets('a line of Tamil is exactly as tall as a line of Latin, with the same baseline', (tester) async {
    const tamil = 'பெயர்'; // பெயர்
    await _pump(tester, _group(sources: const [LayerSourceItem(key: '', value: tamil)]));

    expect(tester.getSize(find.text(tamil)).height, closeTo(lineBox, _halfPx));
    expect(_baseline(tester, tamil), closeTo(expectedBaseline, _halfPx));
  });

  testWidgets('mixed Tamil and Latin stays on one baseline in one line box', (tester) async {
    const mixed = 'பெயர் Name 123';
    await _pump(tester, _group(sources: const [LayerSourceItem(key: '', value: mixed)]));

    expect(tester.getSize(find.text(mixed)).height, closeTo(lineBox, _halfPx));
    expect(_baseline(tester, mixed), closeTo(expectedBaseline, _halfPx));
  });

  testWidgets('bold uses the same line box', (tester) async {
    await _pump(tester, _group(bold: true, sources: const [LayerSourceItem(key: '', value: 'Hello')]));

    expect(tester.getSize(find.text('Hello')).height, closeTo(lineBox, _halfPx));
    expect(_baseline(tester, 'Hello'), closeTo(expectedBaseline, _halfPx));
  });

  testWidgets('long text wraps at the layer width, one line box per line', (tester) async {
    final words = List.filled(8, 'wrapping').join(' ');
    await _pump(tester, _group(width: 20, sources: [LayerSourceItem(key: '', value: words)]));

    final size = tester.getSize(find.text(words));
    expect(size.width, lessThanOrEqualTo(20 * _pxPerMm + 0.01));
    final lines = (size.height / lineBox).round();
    expect(lines, greaterThan(2));
    expect(size.height, closeTo(lines * lineBox, lines * _halfPx));
  });

  testWidgets('with a key width, the key, separator and value start at the backend column positions', (tester) async {
    final group = _group(keyWidth: 20, sources: const [LayerSourceItem(key: 'Name', value: 'Asha')]);
    await _pump(tester, group);

    final keyPx = 20 * _pxPerMm;
    final sepPx = fontPx * 0.6;
    expect(tester.getTopLeft(find.text('Name')).dx, 0);
    expect(tester.getTopLeft(find.text(':')).dx, closeTo(keyPx, 0.01));
    expect(tester.getTopLeft(find.text('Asha')).dx, closeTo(keyPx + sepPx, 0.01));
    // All three on the same row.
    expect(tester.getTopLeft(find.text('Asha')).dy, tester.getTopLeft(find.text('Name')).dy);
  });

  testWidgets('without a key width the separator and value follow the key inline', (tester) async {
    await _pump(tester, _group(sources: const [LayerSourceItem(key: 'Name', value: 'Asha')]));

    expect(find.text('Name: Asha'), findsOneWidget);
  });

  testWidgets('several fields stack, each at least the layer line height tall', (tester) async {
    // 10pt at 12px/mm: a line box is ~51px, and lineHeightMm 5 = 60px, so each row is 60px.
    await _pump(
      tester,
      _group(lineHeightMm: 5, sources: const [
        LayerSourceItem(key: '', value: 'One'),
        LayerSourceItem(key: '', value: 'Two'),
      ]),
    );

    expect(tester.getTopLeft(find.text('One')).dy, 0);
    expect(tester.getTopLeft(find.text('Two')).dy, closeTo(5 * _pxPerMm, 0.01));
  });

  testWidgets('a combined layer adds its line gap between every line, exactly', (tester) async {
    Future<double> pitch(double gapMm) async {
      await _pump(
        tester,
        _group(isList: true, gapMm: gapMm, sources: const [
          LayerSourceItem(key: '', value: 'First', separator: 'newline'),
          LayerSourceItem(key: '', value: 'Second'),
        ]),
      );
      // One paragraph of two lines: its height is 2 line boxes.
      return tester.getSize(find.byType(RichText).first).height / 2;
    }

    final normal = await pitch(0);
    final gapped = await pitch(5);
    expect(gapped - normal, closeTo(5 * _pxPerMm, 0.01));
  });

  testWidgets('a layer without width wraps at the default width, like the PDF', (tester) async {
    await _pump(tester, _group(width: null, sources: [LayerSourceItem(key: '', value: List.filled(30, 'word').join(' '))]));

    expect(tester.getSize(find.byType(CardTextLayer)).width, closeTo(CardText.defaultWidthMm * _pxPerMm, 0.01));
  });

  test('the shared constants are the ones the backend uses', () {
    expect(CardText.lineHeightFactor, 1.2); // PdfGenerationService.LineHeightFactor
    expect(CardText.separatorWidthFactor, 0.6); // PdfGenerationService.SeparatorWidthFactor
    expect(CardText.defaultWidthMm, 30); // PdfGenerationService: group.WidthMm ?? 30
  });

  testWidgets('words to remove are taken out of a single field value', (tester) async {
    final group = _group(sources: const [LayerSourceItem(key: '', value: 'எண் :117 கூளமடை')]).copyWith(
      removeWords: const ['எண்'],
    );
    await _pump(tester, group);

    expect(find.text('117 கூளமடை'), findsOneWidget);
    expect(find.text('எண் :117 கூளமடை'), findsNothing);
  });

  testWidgets('words to remove leave the key of a single field alone', (tester) async {
    final group = _group(sources: const [LayerSourceItem(key: 'எண்', value: 'எண் 5')]).copyWith(
      removeWords: const ['எண்'],
    );
    await _pump(tester, group);

    expect(find.text('எண்: 5'), findsOneWidget);
  });

  testWidgets('a date value in a single field is printed in the layer date format', (tester) async {
    final group = _group(sources: const [LayerSourceItem(key: 'பிறந்த தேதி', value: '01-Jan-1968')]).copyWith(
      dateFormat: 'dd/MM/yyyy',
    );
    await _pump(tester, group);

    expect(find.text('பிறந்த தேதி: 01/01/1968'), findsOneWidget);
  });

  testWidgets('a date format leaves a value that is not a date alone', (tester) async {
    final group = _group(sources: const [LayerSourceItem(key: '', value: '614001')]).copyWith(
      dateFormat: 'dd/MM/yyyy',
    );
    await _pump(tester, group);

    expect(find.text('614001'), findsOneWidget);
  });
}
