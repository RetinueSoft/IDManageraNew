// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_card_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GenerateCardController)
final generateCardControllerProvider = GenerateCardControllerProvider._();

final class GenerateCardControllerProvider
    extends $AsyncNotifierProvider<GenerateCardController, GenerateCardState> {
  GenerateCardControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generateCardControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generateCardControllerHash();

  @$internal
  @override
  GenerateCardController create() => GenerateCardController();
}

String _$generateCardControllerHash() =>
    r'3a178c23273ca6a02e21f790a3cba212f99778e5';

abstract class _$GenerateCardController
    extends $AsyncNotifier<GenerateCardState> {
  FutureOr<GenerateCardState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<GenerateCardState>, GenerateCardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GenerateCardState>, GenerateCardState>,
              AsyncValue<GenerateCardState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
