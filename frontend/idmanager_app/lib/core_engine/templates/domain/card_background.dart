import 'card_template.dart';

/// One background a card can be printed on: a front and a back image. A template has its own
/// (the [defaultId] one) and any number of extra ones (its combinations); which one a card uses
/// is chosen in the designer and again in the card generator.
class CardBackground {
  const CardBackground({
    required this.id,
    required this.name,
    required this.frontImageBase64,
    required this.backImageBase64,
  });

  /// The id of the template's own images - what the backend calls combination 0.
  static const defaultId = 0;

  final int id;
  final String name;
  final String frontImageBase64;
  final String backImageBase64;

  bool get isDefault => id == defaultId;
}

extension CardTemplateBackgrounds on CardTemplateDetail {
  /// The template's own images first, then each extra background in the order they were added.
  List<CardBackground> get backgrounds => [
    CardBackground(
      id: CardBackground.defaultId,
      name: 'Default',
      frontImageBase64: template.frontImageBase64,
      backImageBase64: template.backImageBase64,
    ),
    for (final c in combinations)
      CardBackground(
        id: c.id,
        name: c.name,
        frontImageBase64: c.frontImageBase64,
        backImageBase64: c.backImageBase64,
      ),
  ];
}

/// The background with [id], or the first (default) one when there is none - so a background
/// that was just deleted falls back to the template's own.
CardBackground backgroundOrDefault(List<CardBackground> backgrounds, int? id) =>
    backgrounds.firstWhere((b) => b.id == id, orElse: () => backgrounds.first);
