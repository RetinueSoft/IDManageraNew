import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/common/validation_exception.dart';
import 'template_form_state.dart';
import 'template_list_controller.dart';

part 'template_form_controller.g.dart';

/// Backs the Add/Edit Template screen (base fields only - layer positions are
/// edited separately on the designer canvas once the template exists).
/// [templateId] is null in Add mode.
@riverpod
class TemplateFormController extends _$TemplateFormController {
  @override
  Future<TemplateFormState> build(int? templateId) async {
    if (templateId == null) return const TemplateFormState();

    final detail = await ref.watch(templateServiceProvider).getTemplate(templateId);
    if (detail == null) return const TemplateFormState();

    final t = detail.template;
    return TemplateFormState(
      name: t.name,
      cardWidthMm: t.cardWidthMm,
      cardHeightMm: t.cardHeightMm,
      pointCost: t.pointCost,
      isActive: t.isActive,
      existingFrontImageBase64: t.frontImageBase64,
      existingBackImageBase64: t.backImageBase64,
    );
  }

  void updateFields(TemplateFormState Function(TemplateFormState current) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(update(current));
  }

  /// Returns the saved template's id on success, or null on failure.
  Future<int?> save() async {
    final current = state.value;
    if (current == null) return null;

    state = AsyncData(current.copyWith(isSaving: true, errors: const {}));
    final service = ref.read(templateServiceProvider);

    try {
      final int id;
      if (templateId == null) {
        final detail = await service.createTemplate(
          name: current.name,
          cardWidthMm: current.cardWidthMm,
          cardHeightMm: current.cardHeightMm,
          pointCost: current.pointCost,
          frontFile: current.frontFile,
          backFile: current.backFile,
        );
        id = detail.template.id;
      } else {
        await service.updateTemplate(
          id: templateId!,
          name: current.name,
          pointCost: current.pointCost,
          isActive: current.isActive,
        );
        id = templateId!;
      }

      state = AsyncData(current.copyWith(isSaving: false));
      ref.invalidate(templateListControllerProvider);
      return id;
    } on ValidationException catch (e) {
      state = AsyncData(current.copyWith(isSaving: false, errors: e.errors));
      return null;
    }
  }
}
