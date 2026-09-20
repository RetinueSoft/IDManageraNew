import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/application/dashboard/dashboard_controller.dart';
import 'package:idmanager_app/application/security/session_controller.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/dashboard/domain/dashboard_summary.dart';
import 'package:idmanager_app/core_engine/security/domain/user.dart';
import 'package:idmanager_app/infrastructure/repositories/api_dashboard_repository.dart';
import 'package:idmanager_app/presentation/shell/dashboard_screen.dart';
import 'package:idmanager_app/presentation/shell/monthly_bar_chart.dart';

List<MonthlyPoints> twelveMonths({Map<int, (int, int)> byIndex = const {}}) => [
  for (var i = 0; i < 12; i++)
    MonthlyPoints(
      year: i < 3 ? 2025 : 2026,
      month: ((9 + i) % 12) + 1, // Oct 2025 ... Sep 2026
      credit: byIndex[i]?.$1 ?? 0,
      debit: byIndex[i]?.$2 ?? 0,
    ),
];

DashboardSummary summary({int? members = 4, Map<int, (int, int)> byIndex = const {}}) => DashboardSummary(
  balance: 97,
  creditThisMonth: 12,
  debitThisMonth: 3,
  creditTotal: 300,
  debitTotal: 200,
  cardsThisMonth: 6,
  cardsTotal: 41,
  membersCount: members,
  months: twelveMonths(byIndex: byIndex),
);

final _me = User(
  id: 1,
  name: 'Admin',
  phone: '9999999999',
  role: UserRole.superAdmin,
  isActive: true,
  points: 0,
  createdAt: DateTime(2024),
);

class _FakeSession extends SessionController {
  @override
  Future<User?> build() async => _me;
}

Future<void> pumpDashboard(WidgetTester tester, DashboardSummary data, {double width = 1400}) async {
  tester.view.physicalSize = Size(width, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionControllerProvider.overrideWith(_FakeSession.new),
        dashboardSummaryProvider.overrideWith((ref) async => data),
      ],
      child: const MaterialApp(home: DashboardScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MonthlyBarChart.niceMax', () {
    test('rounds the top of the scale up to a readable number', () {
      expect(MonthlyBarChart.niceMax(0), 1);
      expect(MonthlyBarChart.niceMax(3), 5);
      expect(MonthlyBarChart.niceMax(5), 5);
      expect(MonthlyBarChart.niceMax(7), 10);
      expect(MonthlyBarChart.niceMax(10), 10);
      expect(MonthlyBarChart.niceMax(11), 20);
      expect(MonthlyBarChart.niceMax(20), 20);
      expect(MonthlyBarChart.niceMax(21), 50);
      expect(MonthlyBarChart.niceMax(130), 200);
      expect(MonthlyBarChart.niceMax(500), 500);
      expect(MonthlyBarChart.niceMax(501), 1000);
      expect(MonthlyBarChart.niceMax(9999), 10000);
    });

    test('the top of the scale is never below the biggest value', () {
      for (final v in [1, 2, 9, 10, 11, 19, 50, 99, 100, 101, 999, 1234, 87654]) {
        expect(MonthlyBarChart.niceMax(v), greaterThanOrEqualTo(v), reason: '$v');
      }
    });
  });

  group('monthLabel', () {
    test('leaves the year out for the current one and adds it for another', () {
      const oct25 = MonthlyPoints(year: 2025, month: 10, credit: 0, debit: 0);
      const sep26 = MonthlyPoints(year: 2026, month: 9, credit: 0, debit: 0);

      expect(monthLabel(sep26, currentYear: 2026), 'Sep');
      expect(monthLabel(oct25, currentYear: 2026), 'Oct 25');
    });
  });

  test('the dashboard JSON is read, with missing numbers as zero', () {
    final data = dashboardSummaryFromJson({
      'balance': 97,
      'creditThisMonth': 12,
      'cardsTotal': 41,
      'membersCount': null,
      'months': [
        {'year': 2026, 'month': 9, 'credit': 5, 'debit': 2},
        {'year': 2026, 'month': 8},
      ],
    });

    expect(data.balance, 97);
    expect(data.debitThisMonth, 0);
    expect(data.cardsTotal, 41);
    expect(data.membersCount, isNull);
    expect(data.months.map((m) => (m.month, m.credit, m.debit)), [(9, 5, 2), (8, 0, 0)]);
    expect(dashboardSummaryFromJson({}).months, isEmpty);
  });

  group('the chart', () {
    Widget chart(List<int> values) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 700,
          child: MonthlyBarChart(
            title: 'Credited',
            labels: [for (var i = 0; i < values.length; i++) 'M$i'],
            values: values,
            color: Colors.green,
            height: 200,
          ),
        ),
      ),
    );

    testWidgets('bars share one scale: twice the value is twice as tall', (tester) async {
      await tester.pumpWidget(chart([0, 20, 40, 10]));

      double heightOf(int i) => tester.getSize(find.descendant(of: find.byKey(ValueKey('bar-$i')), matching: find.byType(Container))).height;
      expect(heightOf(0), 0);
      expect(heightOf(2), closeTo(heightOf(1) * 2, 0.5));
      expect(heightOf(3), closeTo(heightOf(1) / 2, 0.5));
    });

    testWidgets('shows each month label and the value above a non-zero bar', (tester) async {
      await tester.pumpWidget(chart([0, 20, 40, 10]));

      for (final label in ['M0', 'M1', 'M2', 'M3']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('20'), findsOneWidget);
      expect(find.text('40'), findsWidgets); // the bar's value (and the top of the scale)
      expect(find.text('0'), findsNothing); // zero months carry no number
    });

    testWidgets('the header adds the months up', (tester) async {
      await tester.pumpWidget(chart([0, 20, 40, 10]));

      expect(find.text('70 in 12 months'), findsOneWidget);
    });

    testWidgets('every month zero says there is nothing, instead of showing bare axes', (tester) async {
      await tester.pumpWidget(chart([0, 0, 0]));

      expect(find.text('Nothing in the last 12 months'), findsOneWidget);
    });

    testWidgets('a bar tells its month and value in a tooltip', (tester) async {
      await tester.pumpWidget(chart([0, 20, 40, 10]));

      final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).map((t) => t.message);
      expect(tooltips, containsAll(['M1: 20 points', 'M2: 40 points']));
    });
  });

  group('the dashboard', () {
    testWidgets('shows the cards', (tester) async {
      await pumpDashboard(tester, summary());

      expect(find.text('Welcome, Admin'), findsOneWidget);
      for (final (value, label) in [
        ('97', 'Point balance'),
        ('12', 'Credited this month'),
        ('3', 'Debited this month'),
        ('6', 'Cards this month'),
        ('41', 'Cards as of now'),
        ('4', 'Members'),
        ('300', 'Credited as of now'),
        ('200', 'Debited as of now'),
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
        expect(find.text(value), findsWidgets, reason: value);
      }
    });

    testWidgets('two rows: the balance alone, then the points and the cards together', (tester) async {
      await pumpDashboard(tester, summary());

      Offset at(String label) => tester.getTopLeft(find.text(label));
      final balance = at('Point balance');
      final row = [
        at('Credited this month'),
        at('Debited this month'),
        at('Credited as of now'),
        at('Debited as of now'),
        at('Cards this month'),
        at('Cards as of now'),
        at('Members'),
      ];

      // Row 1: the balance by itself.
      for (final card in row) {
        expect(card.dy, greaterThan(balance.dy + 20));
      }
      // Row 2: all of them on one line, in this order, left to right.
      for (final card in row) {
        expect(card.dy, closeTo(row.first.dy, 1));
      }
      for (var i = 0; i < row.length - 1; i++) {
        expect(row[i].dx, lessThan(row[i + 1].dx), reason: 'card $i');
      }
    });

    Rect cardOf(WidgetTester tester, String label) =>
        tester.getRect(find.ancestor(of: find.text(label), matching: find.byType(Card)).first);

    testWidgets('each row is stretched across the full width', (tester) async {
      await pumpDashboard(tester, summary());
      // The page is 1400 wide with 24 padding each side.
      const left = 24.0, right = 1400.0 - 24.0;

      final balance = cardOf(tester, 'Point balance');
      final first = cardOf(tester, 'Credited this month');
      final last = cardOf(tester, 'Members');

      // The balance card spans the whole row.
      expect(balance.left, closeTo(left, 1));
      expect(balance.right, closeTo(right, 1));
      // The second row starts at the left edge and ends at the right edge...
      expect(first.left, closeTo(left, 1));
      expect(last.right, closeTo(right, 1));
      // ...with every card the same width.
      final widths = [
        for (final l in ['Credited this month', 'Debited this month', 'Credited as of now', 'Debited as of now', 'Cards this month', 'Cards as of now', 'Members'])
          cardOf(tester, l).width,
      ];
      for (final w in widths) {
        expect(w, closeTo(widths.first, 0.5));
      }
    });

    testWidgets('without a Members card the rest still fill the row', (tester) async {
      await pumpDashboard(tester, summary(members: null));

      expect(cardOf(tester, 'Credited this month').left, closeTo(24, 1));
      expect(cardOf(tester, 'Cards as of now').right, closeTo(1400 - 24, 1));
    });

    testWidgets('on a narrow window the second row wraps, every line still filling the width', (tester) async {
      await pumpDashboard(tester, summary(), width: 700);

      final first = cardOf(tester, 'Credited this month');
      final last = cardOf(tester, 'Members');
      // More than one line...
      expect(last.top, greaterThan(first.top + 20));
      // ...and the cards are wider than the minimum, using the space, and stay inside the page.
      expect(first.width, greaterThan(170));
      expect(cardOf(tester, 'Debited this month').right, lessThanOrEqualTo(700 - 24 + 1));
    });

    testWidgets('a member without member screens has no Members card', (tester) async {
      await pumpDashboard(tester, summary(members: null));

      expect(find.text('Members'), findsNothing);
      expect(find.text('Point balance'), findsOneWidget);
    });

    testWidgets('shows the month-wise credit graph and the month-wise debit graph', (tester) async {
      await pumpDashboard(tester, summary(byIndex: {8: (30, 0), 10: (0, 5), 11: (12, 3)}));

      expect(find.text('Points credited, month by month'), findsOneWidget);
      expect(find.text('Points debited, month by month'), findsOneWidget);
      // Twelve bars each.
      expect(find.byKey(const ValueKey('bar-11')), findsNWidgets(2));
      expect(find.text('42 in 12 months'), findsOneWidget); // credit: 30 + 12
      expect(find.text('8 in 12 months'), findsOneWidget); // debit: 5 + 3
      // Months across the year end are labelled with the year.
      expect(find.text('Oct 25'), findsNWidgets(2));
      expect(find.text('Sep'), findsNWidgets(2));
    });

    testWidgets('on a narrow window the graphs stack instead of squeezing', (tester) async {
      await pumpDashboard(tester, summary(), width: 700);

      final credit = tester.getTopLeft(find.text('Points credited, month by month'));
      final debit = tester.getTopLeft(find.text('Points debited, month by month'));
      expect(debit.dy, greaterThan(credit.dy + 100));
      expect((debit.dx - credit.dx).abs(), lessThan(5));
    });

    testWidgets('on a wide window the graphs sit side by side', (tester) async {
      await pumpDashboard(tester, summary());

      final credit = tester.getTopLeft(find.text('Points credited, month by month'));
      final debit = tester.getTopLeft(find.text('Points debited, month by month'));
      expect((debit.dy - credit.dy).abs(), lessThan(5));
      expect(debit.dx, greaterThan(credit.dx + 300));
    });

    testWidgets('a failed load says so and offers to try again', (tester) async {
      tester.view.physicalSize = const Size(1400, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          // No automatic retries: the error shows at once (the app's default retries a few times first).
          retry: (_, _) => null,
          overrides: [
            sessionControllerProvider.overrideWith(_FakeSession.new),
            dashboardSummaryProvider.overrideWith((ref) async {
              calls++;
              if (calls == 1) throw Exception('server down');
              return summary();
            }),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not load the dashboard'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Point balance'), findsOneWidget);
      expect(calls, 2);
    });
  });
}
