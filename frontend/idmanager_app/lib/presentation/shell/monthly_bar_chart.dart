import 'package:flutter/material.dart';

/// A bar chart with one bar per month. Drawn from plain widgets (no chart package): the bars share
/// one scale, so a bar is exactly as tall as its share of the biggest month, and hovering (or long
/// pressing) a bar tells its month and value.
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    super.key,
    required this.title,
    required this.labels,
    required this.values,
    required this.color,
    this.unit = 'points',
    this.emptyText = 'Nothing in the last 12 months',
    this.height = 200,
  }) : assert(labels.length == values.length);

  final String title;

  /// One per bar, e.g. "Sep".
  final List<String> labels;
  final List<int> values;
  final Color color;

  /// Said after the value in a bar's tooltip.
  final String unit;

  /// Shown across the chart while every month is zero.
  final String emptyText;
  final double height;

  /// The most any bar may reach, in whole units the axis can be read in: 7 shows against 10, 130
  /// against 200. Keeps the tallest bar from touching the top and the scale from being odd.
  static int niceMax(int highest) {
    if (highest <= 0) return 1;
    if (highest <= 10) return highest <= 5 ? 5 : 10;
    var magnitude = 1;
    while (magnitude * 10 <= highest) {
      magnitude *= 10;
    }
    for (final step in [1, 2, 5, 10]) {
      if (highest <= step * magnitude) return step * magnitude;
    }
    return 10 * magnitude;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highest = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    final axisMax = niceMax(highest);
    final total = values.fold<int>(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                Text('$total in 12 months', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: height,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        // Axis: the top of the scale, and the baseline.
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 34,
                                child: Text(
                                  '$axisMax',
                                  style: theme.textTheme.labelSmall,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    for (var i = 0; i < values.length; i++)
                                      Expanded(
                                        child: _Bar(
                                          key: ValueKey('bar-$i'),
                                          label: labels[i],
                                          value: values[i],
                                          fraction: values[i] / axisMax,
                                          color: color,
                                          unit: unit,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 40),
                            for (final label in labels)
                              Expanded(
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: theme.textTheme.labelSmall,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (total == 0)
                    Center(
                      child: Text(
                        emptyText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
    required this.unit,
  });

  final String label;
  final int value;
  final double fraction;
  final Color color;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: '$label: $value $unit',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (value > 0)
              Text(
                '$value',
                style: theme.textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            Flexible(
              child: FractionallySizedBox(
                heightFactor: fraction.clamp(0.0, 1.0),
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: value > 0 ? color : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
