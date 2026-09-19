import 'package:flutter/material.dart';

/// One titled group of fields inside a [ManageMasterScaffold] (e.g. "Identity",
/// "Card Size").
class MasterFormSection extends StatelessWidget {
  const MasterFormSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final child in children) ...[child, const SizedBox(height: 12)],
          ],
        ),
      ),
    );
  }
}
