import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/audit_log_api.dart';
import '../network/auth_api.dart';
import '../network/card_api.dart';
import '../network/points_api.dart';
import '../network/template_api.dart';
import '../network/user_api.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authApiProvider = Provider((ref) => AuthApi(ref.watch(apiClientProvider)));
final userApiProvider = Provider((ref) => UserApi(ref.watch(apiClientProvider)));
final templateApiProvider = Provider((ref) => TemplateApi(ref.watch(apiClientProvider)));
final pointsApiProvider = Provider((ref) => PointsApi(ref.watch(apiClientProvider)));
final cardApiProvider = Provider((ref) => CardApi(ref.watch(apiClientProvider)));
final auditLogApiProvider = Provider((ref) => AuditLogApi(ref.watch(apiClientProvider)));
