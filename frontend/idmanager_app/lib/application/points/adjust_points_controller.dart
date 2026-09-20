import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/common/validation_exception.dart';
import 'adjust_points_state.dart';
import 'points_refresh.dart';

part 'adjust_points_controller.g.dart';

/// Backs the "Allocate / Reclaim points" dialog for a given target user.
@riverpod
class AdjustPointsController extends _$AdjustPointsController {
  @override
  AdjustPointsState build(int userId) => const AdjustPointsState();

  void updateFields(
    AdjustPointsState Function(AdjustPointsState current) update,
  ) {
    state = update(state);
  }

  /// Allocates ([increase]) or reclaims the entered points. Both need a reason - it is what the
  /// points history shows - unless [reasonRequired] is false (a Super Admin's own top-up).
  Future<bool> submit({
    required bool increase,
    bool reasonRequired = true,
  }) async {
    final errors = <String, String>{
      if (state.points <= 0) 'points': 'Enter a positive number of points.',
      if (reasonRequired && state.reason.trim().isEmpty)
        'reason': 'Enter a reason.',
    };
    if (errors.isNotEmpty) {
      state = state.copyWith(errors: errors);
      return false;
    }

    state = state.copyWith(isSaving: true, errors: const {});
    final service = ref.read(pointsServiceProvider);

    try {
      if (increase) {
        await service.allocate(userId, state.points, state.reason.trim());
      } else {
        await service.reclaim(userId, state.points, state.reason.trim());
      }
      state = state.copyWith(isSaving: false);
      refreshPointsData(ref, alsoUserId: userId);
      return true;
    } on ValidationException catch (e) {
      state = state.copyWith(isSaving: false, errors: e.errors);
      return false;
    }
  }
}
