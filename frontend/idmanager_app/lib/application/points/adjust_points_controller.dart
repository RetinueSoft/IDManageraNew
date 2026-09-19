import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/common/validation_exception.dart';
import 'adjust_points_state.dart';
import 'points_history_controller.dart';

part 'adjust_points_controller.g.dart';

/// Backs the "Allocate / Reclaim points" dialog for a given target user.
@riverpod
class AdjustPointsController extends _$AdjustPointsController {
  @override
  AdjustPointsState build(int userId) => const AdjustPointsState();

  void updateFields(AdjustPointsState Function(AdjustPointsState current) update) {
    state = update(state);
  }

  Future<bool> submit({required bool increase}) async {
    if (state.points <= 0) {
      state = state.copyWith(errors: {'points': 'Enter a positive number of points.'});
      return false;
    }

    state = state.copyWith(isSaving: true, errors: const {});
    final service = ref.read(pointsServiceProvider);

    try {
      if (increase) {
        await service.allocate(userId, state.points, state.reason);
      } else {
        await service.reclaim(userId, state.points, state.reason);
      }
      state = state.copyWith(isSaving: false);
      ref.invalidate(pointsHistoryControllerProvider(userId));
      return true;
    } on ValidationException catch (e) {
      state = state.copyWith(isSaving: false, errors: e.errors);
      return false;
    }
  }
}
