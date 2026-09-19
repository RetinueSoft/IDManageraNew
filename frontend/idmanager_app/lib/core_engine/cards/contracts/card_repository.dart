import 'dart:typed_data';

import '../../common/uploaded_file.dart';
import '../../templates/domain/field_group.dart';
import '../domain/generated_card.dart';

abstract interface class CardRepository {
  /// Used by the Admin template designer to preview a sample PDF's extractable
  /// fields before defining group boxes.
  Future<List<ExtractedField>> parsePdf(UploadedFile file);

  Future<GeneratedCard> generate({
    required int templateId,
    required int combinationId,
    required UploadedFile file,

    /// Images for the template's QR slots, keyed by the slot's key.
    Map<String, UploadedFile> qrImages = const {},
  });

  /// Raw, print-ready PDF bytes.
  Future<Uint8List> download(int idCardId);
}
