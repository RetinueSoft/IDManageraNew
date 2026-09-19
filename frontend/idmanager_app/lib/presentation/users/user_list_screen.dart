import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/security/user_list_controller.dart';
import '../routing/app_routes.dart';
import '../shared/master_template/master_list_screen.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListControllerProvider);
    final users = usersAsync.value ?? const [];

    return MasterListScreen(
      title: 'Users',
      items: users,
      isLoading: usersAsync.isLoading,
      primaryText: (u) => u.name,
      secondaryText: (u) => '${u.phone} · ${u.role.label} · ${u.points} pt',
      isActive: (u) => u.isActive,
      matchesSearch: (u, query) {
        final q = query.toLowerCase();
        return u.name.toLowerCase().contains(q) || u.phone.toLowerCase().contains(q);
      },
      onOpen: (context, u) => context.go(AppRoutes.userEdit(u.id)),
      onAdd: () => context.go(AppRoutes.userNew()),
      emptyStateMessage: 'No users yet. Add your first user to get started.',
    );
  }
}
