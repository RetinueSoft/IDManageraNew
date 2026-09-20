import '../../core_engine/dashboard/contracts/dashboard_repository.dart';
import '../../core_engine/dashboard/domain/dashboard_summary.dart';
import '../../foundation/network/api_client.dart';

DashboardSummary dashboardSummaryFromJson(Map<String, dynamic> json) =>
    DashboardSummary(
      balance: json['balance'] as int? ?? 0,
      creditThisMonth: json['creditThisMonth'] as int? ?? 0,
      debitThisMonth: json['debitThisMonth'] as int? ?? 0,
      creditTotal: json['creditTotal'] as int? ?? 0,
      debitTotal: json['debitTotal'] as int? ?? 0,
      cardsThisMonth: json['cardsThisMonth'] as int? ?? 0,
      cardsTotal: json['cardsTotal'] as int? ?? 0,
      membersCount: json['membersCount'] as int?,
      months: [
        for (final m in json['months'] as List<dynamic>? ?? const [])
          MonthlyPoints(
            year: (m as Map<String, dynamic>)['year'] as int? ?? 0,
            month: m['month'] as int? ?? 1,
            credit: m['credit'] as int? ?? 0,
            debit: m['debit'] as int? ?? 0,
          ),
      ],
    );

class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(this._client);

  final ApiClient _client;

  @override
  Future<DashboardSummary> getSummary() => _client.guard(() async {
    final response = await _client.dio.get('/dashboard/summary');
    return dashboardSummaryFromJson(response.data as Map<String, dynamic>);
  });
}
