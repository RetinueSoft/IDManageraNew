import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/points/domain/point_transaction.dart';

part 'points_history_controller.g.dart';

@riverpod
class PointsHistoryController extends _$PointsHistoryController {
  @override
  Future<List<PointTransaction>> build(int userId) async {
    final page = await ref.watch(pointsServiceProvider).getHistory(
      userId,
      includeIncompleteAlso: true,
      pageSize: 100,
    );
    return page.items;
  }
}
