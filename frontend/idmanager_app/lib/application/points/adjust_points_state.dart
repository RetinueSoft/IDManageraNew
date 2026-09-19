import 'package:freezed_annotation/freezed_annotation.dart';

part 'adjust_points_state.freezed.dart';

@freezed
sealed class AdjustPointsState with _$AdjustPointsState {
  const factory AdjustPointsState({
    @Default(0) int points,
    @Default('') String reason,
    @Default(false) bool isSaving,
    @Default(<String, String>{}) Map<String, String> errors,
  }) = _AdjustPointsState;
}
