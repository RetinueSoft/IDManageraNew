import '../../core_engine/common/enums.dart';
import '../../core_engine/common/paged_result.dart';
import '../../core_engine/points/contracts/points_repository.dart';
import '../../core_engine/points/domain/point_transaction.dart';
import '../../foundation/network/api_client.dart';

PointTransaction _fromJson(Map<String, dynamic> json) => PointTransaction(
  date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
  description: json['description'] as String? ?? '',
  points: json['points'] as int? ?? 0,
  type: PointTransType.fromInt(json['type'] as int? ?? 1),
  status: PointStatus.fromInt(json['status'] as int? ?? 1),
);

class ApiPointsRepository implements PointsRepository {
  ApiPointsRepository(this._client);

  final ApiClient _client;

  @override
  Future<int> getBalance() => _client.guard(() async {
    final response = await _client.dio.get('/points/balance');
    return response.data as int;
  });

  @override
  Future<PagedResult<PointTransaction>> getAll(
    int userId, {
    bool includeIncompleteAlso = false,
    int pageIndex = 1,
    int pageSize = 20,
  }) => _client.guard(() async {
    final response = await _client.dio.post(
      '/points/list',
      data: {
        'userId': userId,
        'includeIncompleteAlso': includeIncompleteAlso,
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      },
    );
    return PagedResult.fromJson(response.data as Map<String, dynamic>, _fromJson);
  });

  @override
  Future<int> increase(int userId, int points, String reason) => _client.guard(() async {
    final response = await _client.dio.post(
      '/points/increase',
      data: {'userId': userId, 'points': points, 'reason': reason},
    );
    return response.data as int;
  });

  @override
  Future<int> decrease(int userId, int points, String reason) => _client.guard(() async {
    final response = await _client.dio.post(
      '/points/decrease',
      data: {'userId': userId, 'points': points, 'reason': reason},
    );
    return response.data as int;
  });
}
