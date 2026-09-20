import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core_engine/audit/contracts/audit_log_repository.dart';
import '../core_engine/cards/contracts/card_repository.dart';
import '../core_engine/dashboard/contracts/dashboard_repository.dart';
import '../core_engine/points/contracts/points_repository.dart';
import '../core_engine/security/contracts/auth_repository.dart';
import '../core_engine/security/contracts/user_repository.dart';
import '../core_engine/templates/contracts/template_repository.dart';
import '../foundation/network/api_client.dart';
import '../foundation/storage/token_storage.dart';
import 'repositories/api_audit_log_repository.dart';
import 'repositories/api_card_repository.dart';
import 'repositories/api_dashboard_repository.dart';
import 'repositories/api_points_repository.dart';
import 'repositories/api_template_repository.dart';
import 'repositories/api_user_repository.dart';
import 'repositories/api_auth_repository.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient();

@Riverpod(keepAlive: true)
TokenStorage tokenStorage(Ref ref) => TokenStorage();

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => ApiAuthRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) => ApiUserRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
PointsRepository pointsRepository(Ref ref) => ApiPointsRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
TemplateRepository templateRepository(Ref ref) => ApiTemplateRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
CardRepository cardRepository(Ref ref) => ApiCardRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AuditLogRepository auditLogRepository(Ref ref) => ApiAuditLogRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
DashboardRepository dashboardRepository(Ref ref) => ApiDashboardRepository(ref.watch(apiClientProvider));
