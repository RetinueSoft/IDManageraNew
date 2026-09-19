import '../../foundation/network/api_exception.dart';
import '../common/paged_result.dart';
import '../common/uploaded_file.dart';
import '../common/validation_exception.dart';
import 'contracts/template_repository.dart';
import 'domain/card_template.dart';
import 'domain/template_layer.dart';

class TemplateEngineService {
  TemplateEngineService(this._repository);

  final TemplateRepository _repository;

  Future<PagedResult<CardTemplate>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy}) =>
      _repository.getAll(pageIndex: pageIndex, pageSize: pageSize, searchBy: searchBy);

  Future<CardTemplateDetail?> getById(int id) => _repository.getById(id);

  Future<CardTemplateDetail> create({
    required String name,
    required double cardWidthMm,
    required double cardHeightMm,
    required int pointCost,
    required UploadedFile? frontFile,
    required UploadedFile? backFile,
    String groupsJson = '[]',
  }) async {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['name'] = 'Name is required.';
    if (frontFile == null) errors['frontImage'] = 'Front image is required.';
    if (backFile == null) errors['backImage'] = 'Back image is required.';
    if (errors.isNotEmpty) throw ValidationException(errors);

    try {
      return await _repository.create(
        name: name,
        cardWidthMm: cardWidthMm,
        cardHeightMm: cardHeightMm,
        pointCost: pointCost,
        frontFile: frontFile!,
        backFile: backFile!,
        groupsJson: groupsJson,
      );
    } on ApiException catch (e) {
      if (e.fieldErrors != null) throw ValidationException(e.fieldErrors!);
      rethrow;
    }
  }

  Future<CardTemplateDetail> update({
    required int id,
    required String name,
    required int pointCost,
    required bool isActive,
    String groupsJson = '[]',
    UploadedFile? frontFile,
    UploadedFile? backFile,
  }) async {
    if (name.trim().isEmpty) {
      throw ValidationException({'name': 'Name is required.'});
    }
    try {
      return await _repository.update(
        id: id,
        name: name,
        pointCost: pointCost,
        isActive: isActive,
        groupsJson: groupsJson,
        frontFile: frontFile,
        backFile: backFile,
      );
    } on ApiException catch (e) {
      if (e.fieldErrors != null) throw ValidationException(e.fieldErrors!);
      rethrow;
    }
  }

  Future<void> setActive(int id, bool active) => _repository.setActive(id, active);

  Future<void> saveLayers(int templateId, List<TemplateLayer> layers) =>
      _repository.saveLayers(templateId, layers);

  Future<Combination> addCombination({
    required int templateId,
    required String name,
    required UploadedFile frontFile,
    required UploadedFile backFile,
  }) => _repository.addCombination(
    templateId: templateId,
    name: name,
    frontFile: frontFile,
    backFile: backFile,
  );

  Future<void> deleteCombination(int combinationId) => _repository.deleteCombination(combinationId);
}
