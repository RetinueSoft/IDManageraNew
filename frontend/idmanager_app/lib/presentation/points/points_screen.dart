import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/points/adjust_points_controller.dart';
import '../../application/points/points_history_controller.dart';
import '../../application/security/session_controller.dart';
import '../../application/security/user_list_controller.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/points/domain/point_transaction.dart';
import '../../core_engine/security/domain/user.dart';

class PointsScreen extends ConsumerWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionControllerProvider).value;
    if (user == null) return const SizedBox.shrink();

    final isManager = user.role.canManageMembers;
    final historyAsync = ref.watch(pointsHistoryControllerProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Points')),
      body: Column(
        children: [
          if (isManager) _AllocatePointsPanel(myUserId: user.id, isSuperAdmin: user.role == UserRole.superAdmin),
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load: $e')),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('No point transactions yet.'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) => _TransactionTile(t: items[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.t});

  final PointTransaction t;

  @override
  Widget build(BuildContext context) {
    final isNegative = t.points < 0;
    return ListTile(
      leading: Icon(
        isNegative ? Icons.remove_circle_outline : Icons.add_circle_outline,
        color: isNegative ? Colors.red : Colors.green,
      ),
      title: Text(t.description),
      subtitle: Text('${t.date.toLocal()}'.split('.').first),
      trailing: Text(
        '${isNegative ? '' : '+'}${t.points}',
        style: TextStyle(color: isNegative ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Lets a Distributor/Admin/SuperAdmin allocate or reclaim points for a user
/// beneath them.
class _AllocatePointsPanel extends ConsumerStatefulWidget {
  const _AllocatePointsPanel({required this.myUserId, required this.isSuperAdmin});

  final int myUserId;

  /// The SuperAdmin is the source of all points, so they can add points to their own
  /// balance (top-up); nobody else can adjust their own points.
  final bool isSuperAdmin;

  @override
  ConsumerState<_AllocatePointsPanel> createState() => _AllocatePointsPanelState();
}

class _AllocatePointsPanelState extends ConsumerState<_AllocatePointsPanel> {
  int? _targetUserId;
  final _pointsCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _pointsCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(bool increase) async {
    if (_targetUserId == null) return;
    final provider = adjustPointsControllerProvider(_targetUserId!);
    ref.read(provider.notifier).updateFields(
      (s) => s.copyWith(points: int.tryParse(_pointsCtrl.text) ?? 0, reason: _reasonCtrl.text),
    );
    final ok = await ref.read(provider.notifier).submit(increase: increase);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(increase ? 'Points allocated.' : 'Points reclaimed.')),
      );
      _pointsCtrl.clear();
      _reasonCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userListControllerProvider);
    // Only the logged-in user and the members they created directly: points move one
    // level at a time (docs/member-hierarchy.md, section 5).
    final users = [
      for (final u in usersAsync.value ?? const <User>[])
        if (u.id == widget.myUserId || u.parentId == widget.myUserId) u,
    ];
    // You appear in the list, but your own points can't be adjusted (a SuperAdmin's
    // pool is unlimited; everyone else's balance is changed by the user above them).
    final selectedIsMe = _targetUserId == widget.myUserId;
    final isTopUp = selectedIsMe && widget.isSuperAdmin;
    final state = _targetUserId == null
        ? null
        : ref.watch(adjustPointsControllerProvider(_targetUserId!));

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Allocate / Reclaim points', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _targetUserId,
                    decoration: const InputDecoration(labelText: 'User'),
                    items: [
                      for (final u in users)
                        DropdownMenuItem(
                          value: u.id,
                          child: Text(
                            u.id == widget.myUserId
                                ? '${u.name} (You) · ${u.points} pt'
                                : '${u.name} (${u.role.label}) · ${u.points} pt',
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() => _targetUserId = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _pointsCtrl,
                    decoration: InputDecoration(labelText: 'Points', errorText: state?.errors['points']),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            if (selectedIsMe) ...[
              const SizedBox(height: 8),
              Text(
                isTopUp
                    ? 'This adds points to your own balance. Points you allocate to members are deducted from it.'
                    : 'You cannot allocate or reclaim your own points. Your history is listed below.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            TextField(controller: _reasonCtrl, decoration: const InputDecoration(labelText: 'Reason')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: (state?.isSaving ?? false) || selectedIsMe ? null : () => _submit(false),
                    child: const Text('Reclaim'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: (state?.isSaving ?? false) || (selectedIsMe && !isTopUp) ? null : () => _submit(true),
                    child: Text(isTopUp ? 'Add to my balance' : 'Allocate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
