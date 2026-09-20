import 'contracts/dashboard_repository.dart';
import 'domain/dashboard_summary.dart';

class DashboardEngineService {
  DashboardEngineService(this._repository);

  final DashboardRepository _repository;

  Future<DashboardSummary> getSummary() => _repository.getSummary();
}
