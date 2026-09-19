// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjust_points_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Backs the "Allocate / Reclaim points" dialog for a given target user.

@ProviderFor(AdjustPointsController)
final adjustPointsControllerProvider = AdjustPointsControllerFamily._();

/// Backs the "Allocate / Reclaim points" dialog for a given target user.
final class AdjustPointsControllerProvider
    extends $NotifierProvider<AdjustPointsController, AdjustPointsState> {
  /// Backs the "Allocate / Reclaim points" dialog for a given target user.
  AdjustPointsControllerProvider._({
    required AdjustPointsControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'adjustPointsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adjustPointsControllerHash();

  @override
  String toString() {
    return r'adjustPointsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AdjustPointsController create() => AdjustPointsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdjustPointsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdjustPointsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AdjustPointsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adjustPointsControllerHash() =>
    r'84f8830e82c63f4228cf5d2655e65305824648f8';

/// Backs the "Allocate / Reclaim points" dialog for a given target user.

final class AdjustPointsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AdjustPointsController,
          AdjustPointsState,
          AdjustPointsState,
          AdjustPointsState,
          int
        > {
  AdjustPointsControllerFamily._()
    : super(
        retry: null,
        name: r'adjustPointsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Backs the "Allocate / Reclaim points" dialog for a given target user.

  AdjustPointsControllerProvider call(int userId) =>
      AdjustPointsControllerProvider._(argument: userId, from: this);

  @override
  String toString() => r'adjustPointsControllerProvider';
}

/// Backs the "Allocate / Reclaim points" dialog for a given target user.

abstract class _$AdjustPointsController extends $Notifier<AdjustPointsState> {
  late final _$args = ref.$arg as int;
  int get userId => _$args;

  AdjustPointsState build(int userId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AdjustPointsState, AdjustPointsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdjustPointsState, AdjustPointsState>,
              AdjustPointsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
