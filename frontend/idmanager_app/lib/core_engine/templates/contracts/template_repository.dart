import '../../common/paged_result.dart';
import '../../common/uploaded_file.dart';
import '../domain/card_template.dart';
import '../domain/template_layer.dart';

abstract interface class TemplateRepository {
  Future<PagedResult<CardTemplate>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy});
  Future<CardTemplateDetail?> getById(int id);

  Future<CardTemplateDetail> create({
    required String name,
    required double cardWidthMm,
    required double cardHeightMm,
    required int pointCost,
    required UploadedFile frontFile,
    required UploadedFile backFile,
    String groupsJson = '[]',
  });

  Future<CardTemplateDetail> update({
    required int id,
    required String name,
    required int pointCost,
    required bool isActive,
    String groupsJson = '[]',
    UploadedFile? frontFile,
    UploadedFile? backFile,
  });

  Future<void> setActive(int id, bool active);

  Future<void> saveLayers(int templateId, List<TemplateLayer> layers);

  Future<Combination> addCombination({
    required int templateId,
    required String name,
    required UploadedFile frontFile,
    required UploadedFile backFile,
  });

  Future<void> deleteCombination(int combinationId);
}
