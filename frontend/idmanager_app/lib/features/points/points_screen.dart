import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/points.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/providers.dart';

class PointsScreen extends ConsumerStatefulWidget {
  const PointsScreen({super.key});

  @override
  ConsumerState<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends ConsumerState<PointsScreen> {
  late Future<List<PointTransaction>> _future;

  @override
  void initState() {
    super.initState();
    final userId = ref.read(authProvider).user!.id;
    _future = ref.read(pointsApiProvider).getAll(userId, includeIncompleteAlso: true).then((r) => r.items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Point Transactions')),
      body: FutureBuilder<List<PointTransaction>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No point transactions yet.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final t = items[index];
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
                  style: TextStyle(
                    color: isNegative ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
