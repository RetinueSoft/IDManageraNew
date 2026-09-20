import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/security/session_controller.dart';
import '../../application/security/user_form_controller.dart';
import '../../application/security/user_form_controller.dart'
    show UserFormController;
import '../../core_engine/common/enums.dart';
import '../../core_engine/security/domain/user_profile.dart';
import 'identity_image_picker.dart';
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
  final _shopName = TextEditingController();
  final _shopAddress = TextEditingController();
  final _city = TextEditingController();
  final _pincode = TextEditingController();
  final _idNumber = TextEditingController();
  bool _initialized = false;

  bool get _isEditMode => widget.userId != null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    _shopName.dispose();
    _shopAddress.dispose();
    _city.dispose();
    _pincode.dispose();
    _idNumber.dispose();
    super.dispose();
  }

  void _setProfile(
    UserFormController controller,
    UserProfile Function(UserProfile) update,
  ) => controller.updateFields((s) => s.copyWith(profile: update(s.profile)));

  void _showProblem(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final provider = userFormControllerProvider(widget.userId);
    final formAsync = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final myRole =
        ref.watch(sessionControllerProvider).value?.role ?? UserRole.unknown;
    final isSelf =
        _isEditMode &&
        ref.watch(sessionControllerProvider).value?.id == widget.userId;

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
          _shopName.text = state.profile.shopName;
          _shopAddress.text = state.profile.shopAddress;
          _city.text = state.profile.city;
          _pincode.text = state.profile.pincode;
          _idNumber.text = state.profile.idNumber;
          _initialized = true;
        }

        return ManageMasterScaffold(
          title: _isEditMode ? 'Edit User' : 'Add User',
          isSaving: state.isSaving,
          validationBanner: ManageMasterScaffold.validationBannerFor(
            state.errors,
            const {
              'name',
              'phone',
              'password',
              'shopName',
              'shopAddress',
              'city',
              'pincode',
              'idType',
              'idNumber',
            },
          ),
          onCancel: () => context.go(AppRoutes.users),
          sections: [
            MasterFormSection(
              title: 'Account',
              children: [
                TextField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: state.errors['name'],
                  ),
                  onChanged: (v) =>
                      controller.updateFields((s) => s.copyWith(name: v)),
                ),
                TextField(
                  controller: _phone,
                  enabled: !_isEditMode,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    errorText: state.errors['phone'],
                  ),
                  onChanged: (v) =>
                      controller.updateFields((s) => s.copyWith(phone: v)),
                ),
                // A password can be changed only by the member themselves or a Super
                // Admin (setting the first password when adding a member is fine).
                if (!_isEditMode || isSelf || myRole == UserRole.superAdmin)
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: _isEditMode
                          ? 'Password (leave blank to keep unchanged)'
                          : 'Password',
                      errorText: state.errors['password'],
                    ),
                    onChanged: (v) =>
                        controller.updateFields((s) => s.copyWith(password: v)),
                  ),
                if (!_isEditMode)
                  DropdownButtonFormField<UserRole>(
                    initialValue: state.role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: myRole.creatableRoles
                        .map(
                          (r) =>
                              DropdownMenuItem(value: r, child: Text(r.label)),
                        )
                        .toList(),
                    onChanged: (v) => controller.updateFields(
                      (s) => s.copyWith(role: v ?? UserRole.user),
                    ),
                  ),
                // Only a Super Admin activates or deactivates a member.
                if (_isEditMode && myRole == UserRole.superAdmin)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    subtitle: isSelf
                        ? const Text('You cannot deactivate your own account.')
                        : null,
                    value: state.isActive,
                    onChanged: isSelf
                        ? null
                        : (v) => controller.updateFields(
                            (s) => s.copyWith(isActive: v),
                          ),
                  ),
              ],
            ),
            // Everything below is optional.
            MasterFormSection(
              title: 'Shop details (optional)',
              children: [
                TextField(
                  controller: _shopName,
                  decoration: InputDecoration(
                    labelText: 'Shop name',
                    errorText: state.errors['shopName'],
                  ),
                  onChanged: (v) =>
                      _setProfile(controller, (p) => p.copyWith(shopName: v)),
                ),
                TextField(
                  controller: _shopAddress,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Shop address',
                    errorText: state.errors['shopAddress'],
                  ),
                  onChanged: (v) => _setProfile(
                    controller,
                    (p) => p.copyWith(shopAddress: v),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _city,
                        decoration: InputDecoration(
                          labelText: 'City',
                          errorText: state.errors['city'],
                        ),
                        onChanged: (v) =>
                            _setProfile(controller, (p) => p.copyWith(city: v)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _pincode,
                        decoration: InputDecoration(
                          labelText: 'Pincode',
                          errorText: state.errors['pincode'],
                        ),
                        onChanged: (v) => _setProfile(
                          controller,
                          (p) => p.copyWith(pincode: v),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            MasterFormSection(
              title: 'Identity proof (optional)',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: state.profile.idType,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'ID type',
                          errorText: state.errors['idType'],
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Not given'),
                          ),
                          for (final type in identityTypes)
                            DropdownMenuItem(value: type, child: Text(type)),
                          // A type saved earlier that is not in the list still shows.
                          if (state.profile.idType.isNotEmpty &&
                              !identityTypes.contains(state.profile.idType))
                            DropdownMenuItem(
                              value: state.profile.idType,
                              child: Text(state.profile.idType),
                            ),
                        ],
                        onChanged: (v) => _setProfile(
                          controller,
                          (p) => p.copyWith(idType: v ?? ''),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _idNumber,
                        decoration: InputDecoration(
                          labelText: 'ID number',
                          errorText: state.errors['idNumber'],
                        ),
                        onChanged: (v) => _setProfile(
                          controller,
                          (p) => p.copyWith(idNumber: v),
                        ),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    IdentityImagePicker(
                      label: 'Front',
                      bytes: state.idFront.shown,
                      onPicked: (f) =>
                          controller.chooseImage(IdentitySide.front, f),
                      onRemoved: () =>
                          controller.removeImage(IdentitySide.front),
                      onRejected: _showProblem,
                    ),
                    IdentityImagePicker(
                      label: 'Back',
                      bytes: state.idBack.shown,
                      onPicked: (f) =>
                          controller.chooseImage(IdentitySide.back, f),
                      onRemoved: () =>
                          controller.removeImage(IdentitySide.back),
                      onRejected: _showProblem,
                    ),
                  ],
                ),
              ],
            ),
          ],
          onSave: () async {
            final saved = await controller.save();
            if (!context.mounted) return saved;
            // A picture that could not be uploaded does not undo the save: say so.
            final warning = ref.read(provider).value?.warning;
            if (warning != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(warning)));
            }
            if (saved) context.go(AppRoutes.users);
            return saved;
          },
        );
      },
    );
  }
}
