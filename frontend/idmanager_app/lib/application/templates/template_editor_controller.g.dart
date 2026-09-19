// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Backs the layer designer canvas: a zoomable background image with draggable
/// text/image layers positioned in millimeters. On-screen zoom (InteractiveViewer,
/// in the Presentation layer) never touches this state - only xMm/yMm/widthMm/
/// heightMm/fontSizePt do, so the same numbers this controller saves are exactly
/// what PdfGenerationService prints from on the backend.

@ProviderFor(TemplateEditorController)
final templateEditorControllerProvider = TemplateEditorControllerFamily._();

/// Backs the layer designer canvas: a zoomable background image with draggable
/// text/image layers positioned in millimeters. On-screen zoom (InteractiveViewer,
/// in the Presentation layer) never touches this state - only xMm/yMm/widthMm/
/// heightMm/fontSizePt do, so the same numbers this controller saves are exactly
/// what PdfGenerationService prints from on the backend.
final class TemplateEditorControllerProvider
    extends
        $AsyncNotifierProvider<TemplateEditorController, TemplateEditorState> {
  /// Backs the layer designer canvas: a zoomable background image with draggable
  /// text/image layers positioned in millimeters. On-screen zoom (InteractiveViewer,
  /// in the Presentation layer) never touches this state - only xMm/yMm/widthMm/
  /// heightMm/fontSizePt do, so the same numbers this controller saves are exactly
  /// what PdfGenerationService prints from on the backend.
  TemplateEditorControllerProvider._({
    required TemplateEditorControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'templateEditorControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$templateEditorControllerHash();

  @override
  String toString() {
    return r'templateEditorControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TemplateEditorController create() => TemplateEditorController();

  @override
  bool operator ==(Object other) {
    return other is TemplateEditorControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$templateEditorControllerHash() =>
    r'fe17c2a2615175c41ed351ae383dc4e0fbf769df';

/// Backs the layer designer canvas: a zoomable background image with draggable
/// text/image layers positioned in millimeters. On-screen zoom (InteractiveViewer,
/// in the Presentation layer) never touches this state - only xMm/yMm/widthMm/
/// heightMm/fontSizePt do, so the same numbers this controller saves are exactly
/// what PdfGenerationService prints from on the backend.

final class TemplateEditorControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TemplateEditorController,
          AsyncValue<TemplateEditorState>,
          TemplateEditorState,
          FutureOr<TemplateEditorState>,
          int
        > {
  TemplateEditorControllerFamily._()
    : super(
        retry: null,
        name: r'templateEditorControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Backs the layer designer canvas: a zoomable background image with draggable
  /// text/image layers positioned in millimeters. On-screen zoom (InteractiveViewer,
  /// in the Presentation layer) never touches this state - only xMm/yMm/widthMm/
  /// heightMm/fontSizePt do, so the same numbers this controller saves are exactly
  /// what PdfGenerationService prints from on the backend.

  TemplateEditorControllerProvider call(int templateId) =>
      TemplateEditorControllerProvider._(argument: templateId, from: this);

  @override
  String toString() => r'templateEditorControllerProvider';
}

/// Backs the layer designer canvas: a zoomable background image with draggable
/// text/image layers positioned in millimeters. On-screen zoom (InteractiveViewer,
/// in the Presentation layer) never touches this state - only xMm/yMm/widthMm/
/// heightMm/fontSizePt do, so the same numbers this controller saves are exactly
/// what PdfGenerationService prints from on the backend.

abstract class _$TemplateEditorController
    extends $AsyncNotifier<TemplateEditorState> {
  late final _$args = ref.$arg as int;
  int get templateId => _$args;

  FutureOr<TemplateEditorState> build(int templateId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TemplateEditorState>, TemplateEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TemplateEditorState>, TemplateEditorState>,
              AsyncValue<TemplateEditorState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
