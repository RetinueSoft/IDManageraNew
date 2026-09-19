import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/security/user_form_controller.dart';
import '../../core_engine/common/enums.dart';
import '../routing/app_routes.dart';
import '../shared/master_template/manage_master_scaffold.dart';
import '../shared/master_template/master_form_section.dart';

/// Add/Edit screen for User. [userId] is null in Add mode.
class ManageUserScreen extends ConsumerStatefulWidget {
  const ManageUserScreen({super.key, this.userId});

  final int? userId;

  @override
  ConsumerState<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends ConsumerState<ManageUserScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _initialized = false;

  bool get _isEditMode => widget.userId != null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = userFormControllerProvider(widget.userId);
    final formAsync = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return formAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(_isEditMode ? 'Edit User' : 'Add User')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('User')),
        body: Center(child: Text('Error: $error')),
      ),
      data: (state) {
        if (!_initialized) {
          _name.text = state.name;
          _phone.text = state.phone;
          _initialized = true;
        }

        return ManageMasterScaffold(
          title: _isEditMode ? 'Edit User' : 'Add User',
          isSaving: state.isSaving,
          validationBanner: ManageMasterScaffold.validationBannerFor(
            state.errors,
            const {'name', 'phone', 'password'},
          ),
          onCancel: () => context.go(AppRoutes.users),
          sections: [
            MasterFormSection(
              title: 'Identity',
              children: [
                TextField(
                  controller: _name,
                  decoration: InputDecoration(labelText: 'Name', errorText: state.errors['name']),
                  onChanged: (v) => controller.updateFields((s) => s.copyWith(name: v)),
                ),
                TextField(
                  controller: _phone,
                  enabled: !_isEditMode,
                  decoration: InputDecoration(labelText: 'Phone', errorText: state.errors['phone']),
                  onChanged: (v) => controller.updateFields((s) => s.copyWith(phone: v)),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _isEditMode ? 'Password (leave blank to keep unchanged)' : 'Password',
                    errorText: state.errors['password'],
                  ),
                  onChanged: (v) => controller.updateFields((s) => s.copyWith(password: v)),
                ),
                if (!_isEditMode)
                  DropdownButtonFormField<UserRole>(
                    initialValue: state.role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: [UserRole.admin, UserRole.distributor, UserRole.user]
                        .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                        .toList(),
                    onChanged: (v) =>
                        controller.updateFields((s) => s.copyWith(role: v ?? UserRole.user)),
                  ),
                if (_isEditMode)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: state.isActive,
                    onChanged: (v) => controller.updateFields((s) => s.copyWith(isActive: v)),
                  ),
              ],
            ),
          ],
          onSave: () async {
            final saved = await controller.save();
            if (saved && context.mounted) context.go(AppRoutes.users);
            return saved;
          },
        );
      },
    );
  }
}
