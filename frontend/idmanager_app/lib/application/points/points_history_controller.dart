import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/points/domain/point_transaction.dart';

part 'points_history_controller.g.dart';

@riverpod
class PointsHistoryController extends _$PointsHistoryController {
  @override
  /// Only completed transactions, unless [includeIncomplete] (a Super Admin's "show pending and
  /// failed" switch) - and the server only honours that for a Super Admin.
  Future<List<PointTransaction>> build(
    int userId, {
    bool includeIncomplete = false,
  }) async {
    final page = await ref
        .watch(pointsServiceProvider)
        .getHistory(
          userId,
          includeIncompleteAlso: includeIncomplete,
          pageSize: 100,
        );
    return page.items;
  }
}
