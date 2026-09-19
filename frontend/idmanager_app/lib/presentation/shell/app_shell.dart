import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/security/session_controller.dart';
import '../../core_engine/common/enums.dart';
import '../routing/app_routes.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.path, this.allowedRoles);
  final String label;
  final IconData icon;
  final String path;
  final List<UserRole> allowedRoles;
}

// Who sees which menu item - docs/member-hierarchy.md, sections 2 and 7.
const _allRoles = [UserRole.superAdmin, UserRole.distributor, UserRole.retailer, UserRole.user];
const _superAdminOnly = [UserRole.superAdmin]; // templates, audit log
const _managerRoles = [UserRole.superAdmin, UserRole.distributor, UserRole.retailer]; // members

final _navItems = [
  const _NavItem('Dashboard', Icons.dashboard_outlined, AppRoutes.dashboard, _allRoles),
  const _NavItem('Templates', Icons.badge_outlined, AppRoutes.templates, _superAdminOnly),
  const _NavItem('Generate Card', Icons.add_card_outlined, AppRoutes.generateCard, _allRoles),
  const _NavItem('Users', Icons.people_outline, AppRoutes.users, _managerRoles),
  const _NavItem('Points', Icons.stars_outlined, AppRoutes.points, _allRoles),
  const _NavItem('Audit Log', Icons.history, AppRoutes.auditLog, _superAdminOnly),
];

/// The Menu Engine's persistent shell: a navigation rail plus Logout wraps every
/// real destination, mirroring the platform's "one cohesive application" principle
/// rather than each screen rebuilding its own chrome.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(sessionControllerProvider).value?.role ?? UserRole.unknown;
    final items = _navItems.where((i) => i.allowedRoles.contains(role)).toList();
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = items.indexWhere((i) => location == i.path || location.startsWith('${i.path}/'));

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            onDestinationSelected: (i) => context.go(items[i].path),
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.badge, size: 32),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Log out',
                    onPressed: () => ref.read(sessionControllerProvider.notifier).logout(),
                  ),
                ),
              ),
            ),
            destinations: [
              for (final i in items) NavigationRailDestination(icon: Icon(i.icon), label: Text(i.label)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
