// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TemplateListController)
final templateListControllerProvider = TemplateListControllerProvider._();

final class TemplateListControllerProvider
    extends $AsyncNotifierProvider<TemplateListController, List<CardTemplate>> {
  TemplateListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'templateListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$templateListControllerHash();

  @$internal
  @override
  TemplateListController create() => TemplateListController();
}

String _$templateListControllerHash() =>
    r'de4b98accbcaa5ff6bdef0baac1b72841e5748b7';

abstract class _$TemplateListController
    extends $AsyncNotifier<List<CardTemplate>> {
  FutureOr<List<CardTemplate>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CardTemplate>>, List<CardTemplate>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CardTemplate>>, List<CardTemplate>>,
              AsyncValue<List<CardTemplate>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
