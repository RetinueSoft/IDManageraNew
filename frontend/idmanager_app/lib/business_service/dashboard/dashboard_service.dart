import '../../core_engine/dashboard/dashboard_engine.dart';
import '../../core_engine/dashboard/domain/dashboard_summary.dart';

class DashboardService {
  DashboardService(this._engine);

  final DashboardEngineService _engine;

  Future<DashboardSummary> getSummary() => _engine.getSummary();
}
