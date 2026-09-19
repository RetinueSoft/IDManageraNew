import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core_engine/providers.dart';
import '../infrastructure/providers.dart';
import 'audit/audit_log_service.dart';
import 'cards/card_generation_service.dart';
import 'points/points_service.dart';
import 'security/auth_service.dart';
import 'security/user_service.dart';
import 'templates/template_service.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => AuthService(
  ref.watch(authEngineServiceProvider),
  ref.watch(apiClientProvider),
  ref.watch(tokenStorageProvider),
);

@Riverpod(keepAlive: true)
UserService userService(Ref ref) => UserService(ref.watch(userEngineServiceProvider));

@Riverpod(keepAlive: true)
PointsService pointsService(Ref ref) => PointsService(ref.watch(pointsEngineServiceProvider));

@Riverpod(keepAlive: true)
TemplateService templateService(Ref ref) =>
    TemplateService(ref.watch(templateEngineServiceProvider));

@Riverpod(keepAlive: true)
CardGenerationService cardGenerationService(Ref ref) => CardGenerationService(
  ref.watch(cardsEngineServiceProvider),
  ref.watch(templateEngineServiceProvider),
);

@Riverpod(keepAlive: true)
AuditLogService auditLogService(Ref ref) =>
    AuditLogService(ref.watch(auditLogEngineServiceProvider));
