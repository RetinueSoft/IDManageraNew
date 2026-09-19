import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums.dart';

part 'point_transaction.freezed.dart';

@freezed
sealed class PointTransaction with _$PointTransaction {
  const factory PointTransaction({
    required DateTime date,
    required String description,
    required int points,
    required PointTransType type,
    required PointStatus status,
  }) = _PointTransaction;
}
