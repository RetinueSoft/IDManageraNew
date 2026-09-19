import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/common/id_generator.dart';
import '../../core_engine/templates/domain/template_layer.dart';
import 'template_editor_state.dart';

part 'template_editor_controller.g.dart';

/// Backs the layer designer canvas: a zoomable background image with draggable
/// text/image layers positioned in millimeters. On-screen zoom (InteractiveViewer,
/// in the Presentation layer) never touches this state - only xMm/yMm/widthMm/
/// heightMm/fontSizePt do, so the same numbers this controller saves are exactly
/// what PdfGenerationService prints from on the backend.
@riverpod
class TemplateEditorController extends _$TemplateEditorController {
  @override
  Future<TemplateEditorState> build(int templateId) async {
    final detail = await ref.watch(templateServiceProvider).getTemplate(templateId);
    if (detail == null) throw StateError('Template $templateId not found.');

    final layers = List<TemplateLayer>.from(detail.layers);
    for (final side in CardSide.values) {
      if (layers.every((l) => l.side != side)) {
        layers.add(TemplateLayer(side: side));
      }
    }

    return TemplateEditorState(template: detail, layers: layers);
  }

  TemplateLayer _currentLayer(TemplateEditorState s) =>
      s.layers.firstWhere((l) => l.side == s.side);

  void selectSide(CardSide side) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(side: side, selectedGroupId: null));
  }

  void selectGroup(String? groupId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedGroupId: groupId));
  }

  void addGroup(LayerFieldType type) {
    final current = state.value;
    if (current == null) return;

    final id = IdGenerator.generate();
    final group = LayerGroup(
      id: id,
      name: type == LayerFieldType.text ? 'New Text' : 'New Image',
      fieldType: type,
      xMm: current.template.template.cardWidthMm / 2 - 10,
      yMm: current.template.template.cardHeightMm / 2 - 5,
      widthMm: type == LayerFieldType.image ? 20 : 30,
      heightMm: type == LayerFieldType.image ? 20 : null,
      sources: [
        LayerSourceItem(
          key: type == LayerFieldType.text ? 'Label' : null,
          value: type == LayerFieldType.text ? 'Sample' : null,
          type: type,
        ),
      ],
    );

    state = AsyncData(current.copyWith(
      layers: _replaceCurrentGroups(current, [..._currentLayer(current).groups, group]),
      selectedGroupId: id,
    ));
  }

  void deleteSelected() {
    final current = state.value;
    if (current == null || current.selectedGroupId == null) return;

    final groups = _currentLayer(current).groups.where((g) => g.id != current.selectedGroupId).toList();
    state = AsyncData(current.copyWith(
      layers: _replaceCurrentGroups(current, groups),
      selectedGroupId: null,
    ));
  }

  void updateGroup(String groupId, LayerGroup Function(LayerGroup current) update) {
    final current = state.value;
    if (current == null) return;

    final groups = [
      for (final g in _currentLayer(current).groups)
        if (g.id == groupId) update(g) else g,
    ];
    state = AsyncData(current.copyWith(layers: _replaceCurrentGroups(current, groups)));
  }

  void moveGroup(String groupId, double dxMm, double dyMm) {
    final current = state.value;
    if (current == null) return;
    final cardWidth = current.template.template.cardWidthMm;
    final cardHeight = current.template.template.cardHeightMm;

    updateGroup(groupId, (g) => g.copyWith(
      xMm: (g.xMm + dxMm).clamp(0, cardWidth - 1),
      yMm: (g.yMm + dyMm).clamp(0, cardHeight - 1),
    ));
  }

  List<TemplateLayer> _replaceCurrentGroups(TemplateEditorState current, List<LayerGroup> groups) => [
    for (final l in current.layers)
      if (l.side == current.side) l.copyWith(groups: groups) else l,
  ];

  Future<bool> save() async {
    final current = state.value;
    if (current == null) return false;

    state = AsyncData(current.copyWith(isSaving: true));
    try {
      await ref.read(templateServiceProvider).saveLayers(templateId, current.layers);
      state = AsyncData(current.copyWith(isSaving: false));
      return true;
    } catch (_) {
      state = AsyncData(current.copyWith(isSaving: false));
      return false;
    }
  }
}
