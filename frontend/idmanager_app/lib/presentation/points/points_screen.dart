import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/points/adjust_points_controller.dart';
import '../../application/points/points_history_controller.dart';
import '../../application/security/session_controller.dart';
import '../../application/security/user_list_controller.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/points/domain/point_transaction.dart';
import '../../core_engine/security/domain/user.dart';

class PointsScreen extends ConsumerStatefulWidget {
  const PointsScreen({super.key});

  @override
  ConsumerState<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends ConsumerState<PointsScreen> {
  /// The member picked in the drop-down; null until one is picked (then it is you).
  int? _selectedUserId;

  /// A Super Admin's switch: also list the pending and failed transactions (off by default).
  bool _showIncomplete = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionControllerProvider).value;
    if (user == null) return const SizedBox.shrink();

    final isManager = user.role.canManageMembers;
    // The history shown is the picked member's; with nobody picked, or yourself picked, it is your own.
    final viewedId = isManager ? (_selectedUserId ?? user.id) : user.id;
    final isSuperAdmin = user.role == UserRole.superAdmin;
    final historyAsync = ref.watch(
      pointsHistoryControllerProvider(
        viewedId,
        includeIncomplete: isSuperAdmin && _showIncomplete,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Points')),
      body: Column(
        children: [
          if (isManager)
            _AllocatePointsPanel(
              myUserId: user.id,
              isSuperAdmin: user.role == UserRole.superAdmin,
              selectedUserId: _selectedUserId,
              onSelected: (id) => setState(() => _selectedUserId = id),
            ),
          if (isManager) _HistoryHeader(viewedId: viewedId, myUserId: user.id),
          // Only a Super Admin can see the pending and failed ones; everyone else sees completed only.
          if (isSuperAdmin)
            SwitchListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text('Show pending and failed transactions'),
              value: _showIncomplete,
              onChanged: (v) => setState(() => _showIncomplete = v),
            ),
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load: $e')),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('No point transactions yet.'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          _TransactionTile(t: items[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Says whose point details are listed below: yours, or the member picked in the drop-down.
class _HistoryHeader extends ConsumerWidget {
  const _HistoryHeader({required this.viewedId, required this.myUserId});

  final int viewedId;
  final int myUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members =
        ref.watch(userListControllerProvider).value ?? const <User>[];
    final viewed = members.where((u) => u.id == viewedId).firstOrNull;
    final isMe = viewedId == myUserId;

    final title = isMe
        ? 'My point details'
        : 'Point details of ${viewed?.name ?? 'the member'}';
    final subtitle = viewed == null
        ? null
        : isMe
        ? '${viewed.points} pt balance'
        : '${viewed.role.label} · ${viewed.points} pt balance';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Icon(isMe ? Icons.person : Icons.people_outline, size: 20),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (subtitle != null) ...[
            const SizedBox(width: 12),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// "Pending" / "Failed" next to a transaction that is not completed.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PointStatus status;

  @override
  Widget build(BuildContext context) {
    final failed = status == PointStatus.failed;
    final color = failed ? Colors.red : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        failed ? 'Failed' : 'Pending',
        style: TextStyle(
          fontSize: 11,
          color: color.shade800,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The size of the points figure in the history list - clearly bigger than the list's other text
/// (the description is about 16, the date about 14).
const pointsFontSize = 22.0;

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
      subtitle: Row(
        children: [
          Text('${t.date.toLocal()}'.split('.').first),
          // Only shown for the rows a Super Admin asked for: completed ones need no label.
          if (t.status != PointStatus.completed) ...[
            const SizedBox(width: 8),
            _StatusBadge(status: t.status),
          ],
        ],
      ),
      trailing: Text(
        '${isNegative ? '' : '+'}${t.points}',
        // The points are what the eye looks for in this list, so they are set larger than the
        // description and date beside them.
        style: TextStyle(
          color: isNegative ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: pointsFontSize,
        ),
      ),
    );
  }
}

/// Lets a Distributor / Retailer / SuperAdmin allocate points to their own members, and a
/// SuperAdmin also reclaim them.
class _AllocatePointsPanel extends ConsumerStatefulWidget {
  const _AllocatePointsPanel({
    required this.myUserId,
    required this.isSuperAdmin,
    required this.selectedUserId,
    required this.onSelected,
  });

  final int myUserId;

  /// The member picked in the drop-down (null: none yet). Owned by the screen, which also shows
  /// that member's point details.
  final int? selectedUserId;
  final ValueChanged<int?> onSelected;

  /// The SuperAdmin is the source of all points, so they can add points to their own
  /// balance (top-up); nobody else can adjust their own points.
  final bool isSuperAdmin;

  @override
  ConsumerState<_AllocatePointsPanel> createState() =>
      _AllocatePointsPanelState();
}

class _AllocatePointsPanelState extends ConsumerState<_AllocatePointsPanel> {
  int? get _targetUserId => widget.selectedUserId;
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
    ref
        .read(provider.notifier)
        .updateFields(
          (s) => s.copyWith(
            points: int.tryParse(_pointsCtrl.text) ?? 0,
            reason: _reasonCtrl.text,
          ),
        );
    // Every allocation and reclaim needs a reason; only a Super Admin's own top-up may leave it out.
    final topUp = _targetUserId == widget.myUserId && widget.isSuperAdmin;
    final ok = await ref
        .read(provider.notifier)
        .submit(increase: increase, reasonRequired: !topUp);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(increase ? 'Points allocated.' : 'Points reclaimed.'),
        ),
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
            Text(
              widget.isSuperAdmin
                  ? 'Allocate / Reclaim points'
                  : 'Allocate points',
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
                    onChanged: widget.onSelected,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _pointsCtrl,
                    decoration: InputDecoration(
                      labelText: 'Points',
                      errorText: state?.errors['points'],
                    ),
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
            TextField(
              controller: _reasonCtrl,
              decoration: InputDecoration(
                labelText: isTopUp ? 'Reason (optional)' : 'Reason (required)',
                errorText: state?.errors['reason'],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Only a Super Admin can take points back, so nobody else is even offered it.
                if (widget.isSuperAdmin) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: (state?.isSaving ?? false) || selectedIsMe
                          ? null
                          : () => _submit(false),
                      child: const Text('Reclaim'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed:
                        (state?.isSaving ?? false) || (selectedIsMe && !isTopUp)
                        ? null
                        : () => _submit(true),
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
