import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/templates/domain/card_background.dart';
import 'package:idmanager_app/core_engine/templates/domain/card_template.dart';

CardTemplateDetail detail({List<Combination> combinations = const []}) => CardTemplateDetail(
  template: CardTemplate(
    id: 1,
    name: 'T',
    cardWidthMm: 85.6,
    cardHeightMm: 54,
    pointCost: 1,
    isActive: true,
    frontImageBase64: 'own-front',
    backImageBase64: 'own-back',
    createdAt: DateTime(2024),
  ),
  combinations: combinations,
);

void main() {
  test('a template own images are the first, default background', () {
    final backgrounds = detail().backgrounds;

    expect(backgrounds, hasLength(1));
    expect(backgrounds.single.id, CardBackground.defaultId);
    expect(backgrounds.single.isDefault, isTrue);
    expect(backgrounds.single.frontImageBase64, 'own-front');
    expect(backgrounds.single.backImageBase64, 'own-back');
  });

  test('extra backgrounds follow the default, in the order they were added', () {
    final backgrounds = detail(
      combinations: const [
        Combination(id: 7, name: 'Blue', frontImageBase64: 'b-front', backImageBase64: 'b-back'),
        Combination(id: 9, name: 'Red', frontImageBase64: 'r-front', backImageBase64: 'r-back'),
      ],
    ).backgrounds;

    expect([for (final b in backgrounds) b.name], ['Default', 'Blue', 'Red']);
    expect([for (final b in backgrounds) b.id], [0, 7, 9]);
    expect(backgrounds[1].isDefault, isFalse);
  });

  test('a missing background falls back to the default', () {
    final backgrounds = detail(
      combinations: const [Combination(id: 7, name: 'Blue', frontImageBase64: '', backImageBase64: '')],
    ).backgrounds;

    expect(backgroundOrDefault(backgrounds, 7).name, 'Blue');
    expect(backgroundOrDefault(backgrounds, 99).name, 'Default');
    expect(backgroundOrDefault(backgrounds, null).name, 'Default');
  });
}
