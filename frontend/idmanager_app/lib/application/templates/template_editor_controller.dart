import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/common/id_generator.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/templates/domain/card_background.dart';
import '../../core_engine/templates/domain/field_group.dart';
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
    final detail = await ref
        .watch(templateServiceProvider)
        .getTemplate(templateId);
    if (detail == null) throw StateError('Template $templateId not found.');

    final layers = List<TemplateLayer>.from(detail.layers);
    for (final side in CardSide.values) {
      if (layers.every((l) => l.side != side)) {
        layers.add(TemplateLayer(side: side));
      }
    }

    return TemplateEditorState(
      template: detail,
      layers: layers,
      sampleFields: [for (final g in detail.groups) ...g.items],
    );
  }

  TemplateLayer _currentLayer(TemplateEditorState s) =>
      s.layers.firstWhere((l) => l.side == s.side);

  void selectSide(CardSide side) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(side: side, combined: false, selectedGroupId: null),
    );
  }

  /// Show front and back side by side. The active side is kept.
  void selectCombined() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(combined: true, selectedGroupId: null));
  }

  /// Selects a layer (or nothing, when [groupId] is null) on [side] and makes that side the
  /// active one - how a click on either card in the combined view picks where edits go.
  void selectLayer(CardSide side, String? groupId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(side: side, selectedGroupId: groupId));
  }

  /// Shows the template's background [id] behind the layers (0 = the template's own).
  void selectBackground(int id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedBackgroundId: id));
  }

  /// Adds a background (a front and back image) to the template and shows it. It is saved right
  /// away, like the template's own images - it does not wait for "Save".
  Future<String?> addBackground({
    required String name,
    required UploadedFile front,
    required UploadedFile back,
  }) async {
    final current = state.value;
    if (current == null) return 'Not loaded.';
    try {
      final added = await ref
          .read(templateServiceProvider)
          .addCombination(
            templateId: templateId,
            name: name,
            frontFile: front,
            backFile: back,
          );
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          template: latest.template.copyWith(
            combinations: [...latest.template.combinations, added],
          ),
          selectedBackgroundId: added.id,
        ),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Removes a background from the template (never the template's own).
  Future<String?> deleteBackground(int id) async {
    final current = state.value;
    if (current == null || id == CardBackground.defaultId) return null;
    try {
      await ref.read(templateServiceProvider).deleteCombination(id);
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          template: latest.template.copyWith(
            combinations: [
              for (final c in latest.template.combinations)
                if (c.id != id) c,
            ],
          ),
          selectedBackgroundId: latest.selectedBackgroundId == id
              ? CardBackground.defaultId
              : latest.selectedBackgroundId,
        ),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
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

    state = AsyncData(
      current.copyWith(
        layers: _replaceCurrentGroups(current, [
          ..._currentLayer(current).groups,
          group,
        ]),
        selectedGroupId: id,
      ),
    );
  }

  /// A template has exactly one sample PDF: importing replaces the stored field
  /// palette (already-placed layers are left alone). The fields are persisted with
  /// the template on save. Returns the number of fields found, or null if the PDF
  /// couldn't be read.
  Future<int?> importSamplePdf(UploadedFile file) async {
    final current = state.value;
    if (current == null) return null;

    final List<ExtractedField> fields;
    try {
      fields = await ref.read(cardGenerationServiceProvider).parsePdf(file);
    } catch (_) {
      return null;
    }

    state = AsyncData(current.copyWith(sampleFields: fields));
    return fields.length;
  }

  /// Adds one layer for a field from the sample PDF palette to the current side,
  /// roughly placed (text in a top-down grid, images along the top-right edge)
  /// with default properties, and selects it so the designer sets its properties.
  void addLayerFromField(ExtractedField field) {
    final current = state.value;
    if (current == null) return;

    final template = current.template.template;
    final existing = _currentLayer(current).groups;
    const margin = 2.0;
    const textStepMm = 6.0;
    const textColumnMm = 40.0;
    const imageSizeMm = 20.0;

    final id = IdGenerator.generate();
    final LayerGroup group;
    if (field.type == LayerFieldType.image) {
      final index = existing
          .where((g) => g.fieldType == LayerFieldType.image)
          .length;
      group = LayerGroup(
        id: id,
        name: field.key ?? 'Image',
        fieldType: LayerFieldType.image,
        xMm:
            (template.cardWidthMm -
                    margin -
                    imageSizeMm -
                    index * (imageSizeMm + margin))
                .clamp(0, template.cardWidthMm - 1),
        yMm: margin,
        widthMm: imageSizeMm,
        heightMm: imageSizeMm,
        sources: [
          LayerSourceItem(
            key: field.key,
            value: field.value,
            type: LayerFieldType.image,
          ),
        ],
      );
    } else {
      final index = existing
          .where((g) => g.fieldType == LayerFieldType.text)
          .length;
      final rowsPerColumn = ((template.cardHeightMm - margin) / textStepMm)
          .floor()
          .clamp(1, 1000);
      group = LayerGroup(
        id: id,
        name: field.key ?? 'Text',
        xMm: (margin + (index ~/ rowsPerColumn) * textColumnMm).clamp(
          0,
          template.cardWidthMm - 1,
        ),
        yMm: margin + (index % rowsPerColumn) * textStepMm,
        widthMm: textColumnMm - margin,
        sources: [LayerSourceItem(key: field.key, value: field.value)],
      );
    }

    state = AsyncData(
      current.copyWith(
        layers: _replaceCurrentGroups(current, [...existing, group]),
        selectedGroupId: id,
      ),
    );
  }

  void deleteGroup(String groupId) {
    final current = state.value;
    if (current == null) return;

    final groups = _currentLayer(current).groups
        .where((g) => g.id != groupId)
        .toList();
    state = AsyncData(
      current.copyWith(
        layers: _replaceCurrentGroups(current, groups),
        selectedGroupId: current.selectedGroupId == groupId
            ? null
            : current.selectedGroupId,
      ),
    );
  }

  /// Adds an empty QR code image layer. Nothing is picked here: the card generator
  /// lets the user choose the image for each QR slot (identified by the source key).
  void addQrLayer() {
    final current = state.value;
    if (current == null) return;

    final usedKeys = {
      for (final layer in current.layers)
        for (final g in layer.groups)
          if (g.isQr && g.sources.isNotEmpty) g.sources.first.key,
    };
    var n = usedKeys.length + 1;
    while (usedKeys.contains('QR $n')) {
      n++;
    }

    final id = IdGenerator.generate();
    final group = LayerGroup(
      id: id,
      name: 'QR $n',
      fieldType: LayerFieldType.image,
      isQr: true,
      xMm: current.template.template.cardWidthMm - 22,
      yMm: 2,
      widthMm: 20,
      heightMm: 20,
      sources: [LayerSourceItem(key: 'QR $n', type: LayerFieldType.image)],
    );
    state = AsyncData(
      current.copyWith(
        layers: _replaceCurrentGroups(current, [
          ..._currentLayer(current).groups,
          group,
        ]),
        selectedGroupId: id,
      ),
    );
  }

  /// Adds an empty combined (List) text layer - its fields are added from the
  /// properties panel and rendered as one text joined by a separator.
  void addCombinedGroup() {
    final current = state.value;
    if (current == null) return;

    final id = IdGenerator.generate();
    final group = LayerGroup(
      id: id,
      name: 'Combined',
      xMm: current.template.template.cardWidthMm / 2 - 20,
      yMm: current.template.template.cardHeightMm / 2 - 5,
      widthMm: 40,
      isList: true,
    );
    state = AsyncData(
      current.copyWith(
        layers: _replaceCurrentGroups(current, [
          ..._currentLayer(current).groups,
          group,
        ]),
        selectedGroupId: id,
      ),
    );
  }

  /// Moves the text fields of another layer on the current side into a combined
  /// group, and removes that layer - so existing layers can be combined into one.
  void mergeLayerInto(String groupId, String otherId) {
    final current = state.value;
    if (current == null || groupId == otherId) return;

    final groups = _currentLayer(current).groups;
    final other = groups.where((g) => g.id == otherId).firstOrNull;
    if (other == null) return;

    final merged = [
      for (final g in groups)
        if (g.id == groupId)
          g.copyWith(
            sources: [
              ...g.sources,
              ...other.sources.where((s) => s.type == LayerFieldType.text),
            ],
          )
        else if (g.id != otherId)
          g,
    ];
    state = AsyncData(
      current.copyWith(layers: _replaceCurrentGroups(current, merged)),
    );
  }

  void deleteSelected() {
    final current = state.value;
    if (current == null || current.selectedGroupId == null) return;

    final groups = _currentLayer(current).groups
        .where((g) => g.id != current.selectedGroupId)
        .toList();
    state = AsyncData(
      current.copyWith(
        layers: _replaceCurrentGroups(current, groups),
        selectedGroupId: null,
      ),
    );
  }

  void updateGroup(
    String groupId,
    LayerGroup Function(LayerGroup current) update,
  ) {
    final current = state.value;
    if (current == null) return;

    final groups = [
      for (final g in _currentLayer(current).groups)
        if (g.id == groupId) update(g) else g,
    ];
    state = AsyncData(
      current.copyWith(layers: _replaceCurrentGroups(current, groups)),
    );
  }

  void moveGroup(String groupId, double dxMm, double dyMm) {
    final current = state.value;
    if (current == null) return;
    final cardWidth = current.template.template.cardWidthMm;
    final cardHeight = current.template.template.cardHeightMm;

    updateGroup(
      groupId,
      (g) => g.copyWith(
        xMm: (g.xMm + dxMm).clamp(0, cardWidth - 1),
        yMm: (g.yMm + dyMm).clamp(0, cardHeight - 1),
      ),
    );
  }

  List<TemplateLayer> _replaceCurrentGroups(
    TemplateEditorState current,
    List<LayerGroup> groups,
  ) => [
    for (final l in current.layers)
      if (l.side == current.side) l.copyWith(groups: groups) else l,
  ];

  Future<bool> save() async {
    final current = state.value;
    if (current == null) return false;

    state = AsyncData(current.copyWith(isSaving: true));
    try {
      await ref
          .read(templateServiceProvider)
          .saveLayers(
            templateId,
            current.layers,
            groups: [
              FieldGroup(name: 'Sample PDF', items: current.sampleFields),
            ],
          );
      state = AsyncData(current.copyWith(isSaving: false));
      return true;
    } catch (_) {
      state = AsyncData(current.copyWith(isSaving: false));
      return false;
    }
  }
}
