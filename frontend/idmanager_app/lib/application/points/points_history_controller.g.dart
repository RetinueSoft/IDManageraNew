// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PointsHistoryController)
final pointsHistoryControllerProvider = PointsHistoryControllerFamily._();

final class PointsHistoryControllerProvider
    extends
        $AsyncNotifierProvider<
          PointsHistoryController,
          List<PointTransaction>
        > {
  PointsHistoryControllerProvider._({
    required PointsHistoryControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pointsHistoryControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pointsHistoryControllerHash();

  @override
  String toString() {
    return r'pointsHistoryControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PointsHistoryController create() => PointsHistoryController();

  @override
  bool operator ==(Object other) {
    return other is PointsHistoryControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pointsHistoryControllerHash() =>
    r'34b7f52809c5b7542d0b07a9db54858df1659814';

final class PointsHistoryControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PointsHistoryController,
          AsyncValue<List<PointTransaction>>,
          List<PointTransaction>,
          FutureOr<List<PointTransaction>>,
          int
        > {
  PointsHistoryControllerFamily._()
    : super(
        retry: null,
        name: r'pointsHistoryControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PointsHistoryControllerProvider call(int userId) =>
      PointsHistoryControllerProvider._(argument: userId, from: this);

  @override
  String toString() => r'pointsHistoryControllerProvider';
}

abstract class _$PointsHistoryController
    extends $AsyncNotifier<List<PointTransaction>> {
  late final _$args = ref.$arg as int;
  int get userId => _$args;

  FutureOr<List<PointTransaction>> build(int userId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<PointTransaction>>, List<PointTransaction>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PointTransaction>>,
                List<PointTransaction>
              >,
              AsyncValue<List<PointTransaction>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
