// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_balance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pointsBalance)
final pointsBalanceProvider = PointsBalanceProvider._();

final class PointsBalanceProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  PointsBalanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pointsBalanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pointsBalanceHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return pointsBalance(ref);
  }
}

String _$pointsBalanceHash() => r'e53b62a09a141c310760d01e5b31fe965a386e2f';
