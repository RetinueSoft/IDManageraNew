import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/dashboard/dashboard_controller.dart';
import '../../application/security/session_controller.dart';
import '../../core_engine/dashboard/domain/dashboard_summary.dart';
import 'monthly_bar_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionControllerProvider).value;
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardSummaryProvider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Welcome, ${user?.name ?? ''}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            user?.role.label ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          summaryAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Could not load the dashboard: $e'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => ref.invalidate(dashboardSummaryProvider),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
            data: (summary) => DashboardContent(summary: summary),
          ),
        ],
      ),
    );
  }
}

/// The dashboard's cards and month-wise graphs for [summary].
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The last month is the current one, so its year is "this year": months of another year carry it.
    final currentYear = summary.months.isEmpty
        ? DateTime.now().year
        : summary.months.last.year;
    final labels = [
      for (final m in summary.months) monthLabel(m, currentYear: currentYear),
    ];
    const creditColor = Color(0xFF2E7D32);
    const debitColor = Color(0xFFC62828);

    // Two rows, each stretched across the full width: the balance on its own, then the points
    // (credited and debited this month, then as of now) and the cards (this month, then as of now)
    // together.
    final balanceRow = [
      _StatCard(
        icon: Icons.stars_outlined,
        value: summary.balance,
        label: 'Point balance',
        color: scheme.primary,
      ),
    ];
    final detailRow = [
      _StatCard(
        icon: Icons.south_west,
        value: summary.creditThisMonth,
        label: 'Credited this month',
        color: creditColor,
      ),
      _StatCard(
        icon: Icons.north_east,
        value: summary.debitThisMonth,
        label: 'Debited this month',
        color: debitColor,
      ),
      _StatCard(
        icon: Icons.add_circle_outline,
        value: summary.creditTotal,
        label: 'Credited as of now',
        color: creditColor,
      ),
      _StatCard(
        icon: Icons.remove_circle_outline,
        value: summary.debitTotal,
        label: 'Debited as of now',
        color: debitColor,
      ),
      _StatCard(
        icon: Icons.badge_outlined,
        value: summary.cardsThisMonth,
        label: 'Cards this month',
        color: scheme.tertiary,
      ),
      _StatCard(
        icon: Icons.collections_bookmark_outlined,
        value: summary.cardsTotal,
        label: 'Cards as of now',
        color: scheme.tertiary,
      ),
      if (summary.membersCount != null)
        _StatCard(
          icon: Icons.people_outline,
          value: summary.membersCount!,
          label: 'Members',
          color: scheme.secondary,
        ),
    ];

    final creditChart = MonthlyBarChart(
      title: 'Points credited, month by month',
      labels: labels,
      values: [for (final m in summary.months) m.credit],
      color: creditColor,
      emptyText: 'No points credited in the last 12 months',
    );
    final debitChart = MonthlyBarChart(
      title: 'Points debited, month by month',
      labels: labels,
      values: [for (final m in summary.months) m.debit],
      color: debitColor,
      emptyText: 'No points debited in the last 12 months',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StretchedRow(children: balanceRow),
        const SizedBox(height: 16),
        _StretchedRow(children: detailRow),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 900
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: creditChart),
                    const SizedBox(width: 16),
                    Expanded(child: debitChart),
                  ],
                )
              : Column(
                  children: [
                    creditChart,
                    const SizedBox(height: 16),
                    debitChart,
                  ],
                ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$value',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays cards out so they stretch across the whole width: all in one row when each can keep at
/// least [minCardWidth], otherwise in as many lines as needed, each still filling the full width.
class _StretchedRow extends StatelessWidget {
  const _StretchedRow({required this.children});

  final List<Widget> children;

  static const double minCardWidth = 170;
  static const double gap = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        // How many cards fit on a line at the minimum width (at least one; never more than we have).
        final perLine = ((available + gap) / (minCardWidth + gap))
            .floor()
            .clamp(1, children.length);
        final width = (available - gap * (perLine - 1)) / perLine;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}
