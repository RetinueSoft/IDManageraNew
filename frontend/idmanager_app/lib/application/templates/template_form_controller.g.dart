// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Backs the Add/Edit Template screen (base fields only - layer positions are
/// edited separately on the designer canvas once the template exists).
/// [templateId] is null in Add mode.

@ProviderFor(TemplateFormController)
final templateFormControllerProvider = TemplateFormControllerFamily._();

/// Backs the Add/Edit Template screen (base fields only - layer positions are
/// edited separately on the designer canvas once the template exists).
/// [templateId] is null in Add mode.
final class TemplateFormControllerProvider
    extends $AsyncNotifierProvider<TemplateFormController, TemplateFormState> {
  /// Backs the Add/Edit Template screen (base fields only - layer positions are
  /// edited separately on the designer canvas once the template exists).
  /// [templateId] is null in Add mode.
  TemplateFormControllerProvider._({
    required TemplateFormControllerFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'templateFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$templateFormControllerHash();

  @override
  String toString() {
    return r'templateFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TemplateFormController create() => TemplateFormController();

  @override
  bool operator ==(Object other) {
    return other is TemplateFormControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$templateFormControllerHash() =>
    r'ed23dfb9c260f5ad71447e7a562dd6541f6af11a';

/// Backs the Add/Edit Template screen (base fields only - layer positions are
/// edited separately on the designer canvas once the template exists).
/// [templateId] is null in Add mode.

final class TemplateFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TemplateFormController,
          AsyncValue<TemplateFormState>,
          TemplateFormState,
          FutureOr<TemplateFormState>,
          int?
        > {
  TemplateFormControllerFamily._()
    : super(
        retry: null,
        name: r'templateFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Backs the Add/Edit Template screen (base fields only - layer positions are
  /// edited separately on the designer canvas once the template exists).
  /// [templateId] is null in Add mode.

  TemplateFormControllerProvider call(int? templateId) =>
      TemplateFormControllerProvider._(argument: templateId, from: this);

  @override
  String toString() => r'templateFormControllerProvider';
}

/// Backs the Add/Edit Template screen (base fields only - layer positions are
/// edited separately on the designer canvas once the template exists).
/// [templateId] is null in Add mode.

abstract class _$TemplateFormController
    extends $AsyncNotifier<TemplateFormState> {
  late final _$args = ref.$arg as int?;
  int? get templateId => _$args;

  FutureOr<TemplateFormState> build(int? templateId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TemplateFormState>, TemplateFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TemplateFormState>, TemplateFormState>,
              AsyncValue<TemplateFormState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
