import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/providers.dart';
import 'audit/audit_engine.dart';
import 'cards/cards_engine.dart';
import 'dashboard/dashboard_engine.dart';
import 'points/points_engine.dart';
import 'security/security_engine.dart';
import 'templates/template_engine.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AuthEngineService authEngineService(Ref ref) =>
    AuthEngineService(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
UserEngineService userEngineService(Ref ref) =>
    UserEngineService(ref.watch(userRepositoryProvider));

@Riverpod(keepAlive: true)
PointsEngineService pointsEngineService(Ref ref) =>
    PointsEngineService(ref.watch(pointsRepositoryProvider));

@Riverpod(keepAlive: true)
TemplateEngineService templateEngineService(Ref ref) =>
    TemplateEngineService(ref.watch(templateRepositoryProvider));

@Riverpod(keepAlive: true)
CardsEngineService cardsEngineService(Ref ref) =>
    CardsEngineService(ref.watch(cardRepositoryProvider));

@Riverpod(keepAlive: true)
AuditLogEngineService auditLogEngineService(Ref ref) =>
    AuditLogEngineService(ref.watch(auditLogRepositoryProvider));

@Riverpod(keepAlive: true)
DashboardEngineService dashboardEngineService(Ref ref) =>
    DashboardEngineService(ref.watch(dashboardRepositoryProvider));
