import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/dashboard/domain/dashboard_summary.dart';

part 'dashboard_controller.g.dart';

/// The dashboard's numbers. Not kept alive: opening the dashboard again fetches fresh ones, so it
/// never shows points from before the last card or top-up.
@riverpod
Future<DashboardSummary> dashboardSummary(Ref ref) =>
    ref.watch(dashboardServiceProvider).getSummary();
