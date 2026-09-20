import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/security/session_controller.dart';
import '../audit_log/audit_log_list_screen.dart';
import '../cards/generate_card_screen.dart';
import '../points/points_screen.dart';
import '../shell/app_shell.dart';
import '../shell/dashboard_screen.dart';
import '../templates/manage_template_screen.dart';
import '../templates/template_editor_screen.dart';
import '../templates/template_list_screen.dart';
import '../users/manage_user_screen.dart';
import '../users/user_list_screen.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // A new router at every login and logout, so each login starts on the home screen instead of
  // wherever the previous session left off. (Only the signed-in / signed-out change matters:
  // anything else about the session changing must not throw the user back to the start.)
  ref.watch(
    sessionControllerProvider.select((session) => session.value != null),
  );

  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // The layer designer stays inside the shell so the navigation menu is
          // always reachable from it.
          GoRoute(
            path: AppRoutes.templateDesignPattern,
            builder: (context, state) => TemplateEditorScreen(
              templateId: int.parse(state.pathParameters['templateId']!),
            ),
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.generateCard,
            builder: (context, state) => const GenerateCardScreen(),
          ),
          GoRoute(
            path: AppRoutes.points,
            builder: (context, state) => const PointsScreen(),
          ),
          GoRoute(
            path: AppRoutes.auditLog,
            builder: (context, state) => const AuditLogListScreen(),
          ),
          GoRoute(
            path: AppRoutes.templates,
            builder: (context, state) => const TemplateListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ManageTemplateScreen(),
              ),
              GoRoute(
                path: ':templateId',
                builder: (context, state) => ManageTemplateScreen(
                  templateId: int.parse(state.pathParameters['templateId']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.users,
            builder: (context, state) => const UserListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ManageUserScreen(),
              ),
              GoRoute(
                path: ':userId',
                builder: (context, state) => ManageUserScreen(
                  userId: int.parse(state.pathParameters['userId']!),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
