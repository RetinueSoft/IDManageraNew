import '../../core_engine/cards/domain/downloaded_pdf.dart';
import '../../core_engine/templates/domain/template_layer.dart';

import 'dart:typed_data';

import '../../core_engine/cards/cards_engine.dart';
import '../../core_engine/cards/domain/generated_card.dart';
import '../../core_engine/cards/domain/qr_slot.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/common/lookup_option.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/templates/domain/field_group.dart';
import '../../core_engine/templates/template_engine.dart';

/// Coordinates the Templates and Cards engines for the end-user "generate a card"
/// flow - neither engine depends on the other, so this business_service is where
/// they meet.
class CardGenerationService {
  CardGenerationService(this._cardsEngine, this._templateEngine);

  final CardsEngineService _cardsEngine;
  final TemplateEngineService _templateEngine;

  Future<List<LookupOption>> getCombinationOptions(int templateId) async {
    final template = await _templateEngine.getById(templateId);
    if (template == null) return [];
    return [for (final c in template.combinations) (id: c.id, label: c.name)];
  }

  /// The template's empty QR code image layers - the user picks an image for each
  /// before generating.
  Future<List<QrSlot>> getQrSlots(int templateId) async {
    final template = await _templateEngine.getById(templateId);
    if (template == null) return [];
    return [
      for (final layer in template.layers)
        for (final g in layer.groups)
          if (g.isQr &&
              g.sources.isNotEmpty &&
              (g.sources.first.key ?? '').isNotEmpty)
            (
              key: g.sources.first.key!,
              label:
                  '${g.name} (${layer.side == CardSide.front ? 'front' : 'back'})',
            ),
    ];
  }

  Future<List<ExtractedField>> parsePdf(UploadedFile file) =>
      _cardsEngine.parsePdf(file);

  Future<GeneratedCard> generate({
    required int templateId,
    required int combinationId,
    required UploadedFile file,
    Map<String, UploadedFile> qrImages = const {},
  }) => _cardsEngine.generate(
    templateId: templateId,
    combinationId: combinationId,
    file: file,
    qrImages: qrImages,
  );

  Future<DownloadedPdf> downloadPdf(
    int idCardId,
    List<TemplateLayer> layers,
    int combinationId,
  ) => _cardsEngine.download(idCardId, layers, combinationId);
}
