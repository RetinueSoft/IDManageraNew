import '../models/paged_result.dart';
import '../models/points.dart';
import 'api_client.dart';

class PointsApi {
  final ApiClient _client;
  PointsApi(this._client);

  Future<int> balance() => _client.getJson('/Points/Balance', (data) => data as int);

  Future<PagedResult<PointTransaction>> getAll(
    int userId, {
    bool includeIncompleteAlso = false,
    int pageIndex = 1,
    int pageSize = 20,
  }) =>
      _client.postJson(
        '/Points/GetAll',
        {
          'userId': userId,
          'includeIncompleteAlso': includeIncompleteAlso,
          'pageIndex': pageIndex,
          'pageSize': pageSize,
        },
        (data) => PagedResult.fromJson(
            data as Map<String, dynamic>, (e) => PointTransaction.fromJson(e)),
      );

  Future<int> increase(int userId, int points, String reason) => _client.postJson(
        '/Points/Increase',
        {'userId': userId, 'points': points, 'reason': reason},
        (data) => data as int,
      );

  Future<int> decrease(int userId, int points, String reason) => _client.postJson(
        '/Points/Decrease',
        {'userId': userId, 'points': points, 'reason': reason},
        (data) => data as int,
      );
}
