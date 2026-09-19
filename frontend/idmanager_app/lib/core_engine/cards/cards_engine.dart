import 'dart:typed_data';

import '../../foundation/network/api_exception.dart';
import '../common/uploaded_file.dart';
import '../common/validation_exception.dart';
import '../templates/domain/field_group.dart';
import 'contracts/card_repository.dart';
import 'domain/generated_card.dart';

class CardsEngineService {
  CardsEngineService(this._repository);

  final CardRepository _repository;

  Future<List<ExtractedField>> parsePdf(UploadedFile file) => _repository.parsePdf(file);

  Future<GeneratedCard> generate({
    required int templateId,
    required int combinationId,
    required UploadedFile file,
    Map<String, UploadedFile> qrImages = const {},
  }) async {
    try {
      return await _repository.generate(
        templateId: templateId,
        combinationId: combinationId,
        file: file,
        qrImages: qrImages,
      );
    } on ApiException catch (e) {
      throw ValidationException(e.fieldErrors ?? {'file': e.message});
    }
  }

  Future<Uint8List> download(int idCardId) => _repository.download(idCardId);
}
