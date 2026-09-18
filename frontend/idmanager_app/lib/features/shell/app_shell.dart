import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../core/state/auth_provider.dart';
import '../audit_log/audit_log_screen.dart';
import '../cards/generate_card_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../points/points_screen.dart';
import '../templates/templates_list_screen.dart';
import '../users/users_screen.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final Widget screen;
  final List<UserRole> allowedRoles;
  const _NavItem(this.label, this.icon, this.screen, this.allowedRoles);
}

const _allRoles = [UserRole.superAdmin, UserRole.admin, UserRole.distributor, UserRole.user];
const _adminRoles = [UserRole.superAdmin, UserRole.admin];
const _managerRoles = [UserRole.superAdmin, UserRole.admin, UserRole.distributor];

final _navItems = [
  const _NavItem('Dashboard', Icons.dashboard_outlined, DashboardScreen(), _allRoles),
  const _NavItem('Templates', Icons.badge_outlined, TemplatesListScreen(), _adminRoles),
  const _NavItem('Generate Card', Icons.add_card_outlined, GenerateCardScreen(), _allRoles),
  const _NavItem('Users', Icons.people_outline, UsersScreen(), _managerRoles),
  const _NavItem('Points', Icons.stars_outlined, PointsScreen(), _allRoles),
  const _NavItem('Audit Log', Icons.history, AuditLogScreen(), _adminRoles),
];

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).user?.role ?? UserRole.unknown;
    final items = _navItems.where((i) => i.allowedRoles.contains(role)).toList();
    final safeIndex = _selectedIndex.clamp(0, items.length - 1);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: safeIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
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
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                  ),
                ),
              ),
            ),
            destinations: items
                .map((i) => NavigationRailDestination(icon: Icon(i.icon), label: Text(i.label)))
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: items[safeIndex].screen),
        ],
      ),
    );
  }
}
