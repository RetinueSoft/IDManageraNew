import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/common/paged_result.dart';
import 'package:idmanager_app/core_engine/common/validation_exception.dart';
import 'package:idmanager_app/core_engine/points/contracts/points_repository.dart';
import 'package:idmanager_app/core_engine/points/domain/point_transaction.dart';
import 'package:idmanager_app/core_engine/points/points_engine.dart';
import 'package:idmanager_app/foundation/network/api_exception.dart';

class _FakePointsRepository implements PointsRepository {
  int balance = 0;
  Object? increaseError;
  Object? decreaseError;
  int increaseReturns = 0;
  int decreaseReturns = 0;

  @override
  Future<int> getBalance() async => balance;

  @override
  Future<PagedResult<PointTransaction>> getAll(
    int userId, {
    bool includeIncompleteAlso = false,
    int pageIndex = 1,
    int pageSize = 20,
  }) async => PagedResult(items: const [], totalCount: 0, pageIndex: pageIndex, pageSize: pageSize);

  @override
  Future<int> increase(int userId, int points, String reason) async {
    if (increaseError != null) throw increaseError!;
    return increaseReturns;
  }

  @override
  Future<int> decrease(int userId, int points, String reason) async {
    if (decreaseError != null) throw decreaseError!;
    return decreaseReturns;
  }
}

void main() {
  group('PointsEngineService', () {
    test('getBalance passes through the repository value', () async {
      final repo = _FakePointsRepository()..balance = 42;
      final engine = PointsEngineService(repo);

      expect(await engine.getBalance(), 42);
    });

    test('increase converts a field-error ApiException into a ValidationException', () async {
      final repo = _FakePointsRepository()
        ..increaseError = ApiException('bad', fieldErrors: {'points': 'Not enough points.'});
      final engine = PointsEngineService(repo);

      try {
        await engine.increase(1, 10, 'test');
        fail('expected a ValidationException');
      } on ValidationException catch (e) {
        expect(e.errors['points'], 'Not enough points.');
      }
    });

    test('increase falls back to a generic points error when the API gives no field map', () async {
      final repo = _FakePointsRepository()..increaseError = ApiException('You do not have enough points.');
      final engine = PointsEngineService(repo);

      try {
        await engine.increase(1, 10, 'test');
        fail('expected a ValidationException');
      } on ValidationException catch (e) {
        expect(e.errors['points'], 'You do not have enough points.');
      }
    });

    test('decrease returns the new balance on success', () async {
      final repo = _FakePointsRepository()..decreaseReturns = 5;
      final engine = PointsEngineService(repo);

      expect(await engine.decrease(1, 10, 'test'), 5);
    });
  });
}
