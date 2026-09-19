import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(isActive ? 'Active' : 'Inactive'),
      backgroundColor: isActive ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
