import '../../foundation/network/api_exception.dart';
import '../common/paged_result.dart';
import '../common/validation_exception.dart';
import 'contracts/points_repository.dart';
import 'domain/point_transaction.dart';

class PointsEngineService {
  PointsEngineService(this._repository);

  final PointsRepository _repository;

  Future<int> getBalance() => _repository.getBalance();

  Future<PagedResult<PointTransaction>> getAll(
    int userId, {
    bool includeIncompleteAlso = false,
    int pageIndex = 1,
    int pageSize = 20,
  }) => _repository.getAll(
    userId,
    includeIncompleteAlso: includeIncompleteAlso,
    pageIndex: pageIndex,
    pageSize: pageSize,
  );

  Future<int> increase(int userId, int points, String reason) async {
    try {
      return await _repository.increase(userId, points, reason);
    } on ApiException catch (e) {
      throw ValidationException(e.fieldErrors ?? {'points': e.message});
    }
  }

  Future<int> decrease(int userId, int points, String reason) async {
    try {
      return await _repository.decrease(userId, points, reason);
    } on ApiException catch (e) {
      throw ValidationException(e.fieldErrors ?? {'points': e.message});
    }
  }
}
