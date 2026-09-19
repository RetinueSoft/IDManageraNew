import '../../core_engine/common/paged_result.dart';
import '../../core_engine/points/domain/point_transaction.dart';
import '../../core_engine/points/points_engine.dart';

class PointsService {
  PointsService(this._engine);

  final PointsEngineService _engine;

  Future<int> getBalance() => _engine.getBalance();

  Future<PagedResult<PointTransaction>> getHistory(
    int userId, {
    bool includeIncompleteAlso = false,
    int pageIndex = 1,
    int pageSize = 20,
  }) => _engine.getAll(
    userId,
    includeIncompleteAlso: includeIncompleteAlso,
    pageIndex: pageIndex,
    pageSize: pageSize,
  );

  Future<int> allocate(int userId, int points, String reason) =>
      _engine.increase(userId, points, reason);

  Future<int> reclaim(int userId, int points, String reason) =>
      _engine.decrease(userId, points, reason);
}
