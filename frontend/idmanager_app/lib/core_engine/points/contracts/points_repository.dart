import '../../common/paged_result.dart';
import '../domain/point_transaction.dart';

abstract interface class PointsRepository {
  Future<int> getBalance();

  Future<PagedResult<PointTransaction>> getAll(
    int userId, {
    bool includeIncompleteAlso = false,
    int pageIndex = 1,
    int pageSize = 20,
  });

  /// Returns the target user's new balance.
  Future<int> increase(int userId, int points, String reason);

  /// Returns the target user's new balance.
  Future<int> decrease(int userId, int points, String reason);
}
