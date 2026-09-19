import '../../core_engine/common/lookup_option.dart';
import '../../core_engine/common/paged_result.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/templates/domain/card_template.dart';
import '../../core_engine/templates/domain/template_layer.dart';
import '../../core_engine/templates/template_engine.dart';

class TemplateService {
  TemplateService(this._engine);

  final TemplateEngineService _engine;

  Future<PagedResult<CardTemplate>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy}) =>
      _engine.getAll(pageIndex: pageIndex, pageSize: pageSize, searchBy: searchBy);

  Future<CardTemplateDetail?> getTemplate(int id) => _engine.getById(id);

  /// Active templates only - shown to end users generating a card.
  Future<List<LookupOption>> getActiveTemplateOptions() async {
    final page = await _engine.getAll(pageSize: 200);
    return [
      for (final t in page.items)
        if (t.isActive) (id: t.id, label: t.name),
    ];
  }

  Future<CardTemplateDetail> createTemplate({
    required String name,
    required double cardWidthMm,
    required double cardHeightMm,
    required int pointCost,
    required UploadedFile? frontFile,
    required UploadedFile? backFile,
  }) => _engine.create(
    name: name,
    cardWidthMm: cardWidthMm,
    cardHeightMm: cardHeightMm,
    pointCost: pointCost,
    frontFile: frontFile,
    backFile: backFile,
  );

  Future<CardTemplateDetail> updateTemplate({
    required int id,
    required String name,
    required int pointCost,
    required bool isActive,
  }) => _engine.update(id: id, name: name, pointCost: pointCost, isActive: isActive);

  Future<void> setActive(int id, bool active) => _engine.setActive(id, active);

  Future<void> saveLayers(int templateId, List<TemplateLayer> layers) =>
      _engine.saveLayers(templateId, layers);

  Future<Combination> addCombination({
    required int templateId,
    required String name,
    required UploadedFile frontFile,
    required UploadedFile backFile,
  }) => _engine.addCombination(
    templateId: templateId,
    name: name,
    frontFile: frontFile,
    backFile: backFile,
  );

  Future<void> deleteCombination(int combinationId) => _engine.deleteCombination(combinationId);
}
