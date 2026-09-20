import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/application/security/session_controller.dart';
import 'package:idmanager_app/business_service/points/points_service.dart';
import 'package:idmanager_app/business_service/providers.dart';
import 'package:idmanager_app/business_service/security/user_service.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/common/paged_result.dart';
import 'package:idmanager_app/core_engine/points/domain/point_transaction.dart';
import 'package:idmanager_app/core_engine/security/domain/user.dart';
import 'package:idmanager_app/presentation/points/points_screen.dart';

User member(int id, String name, UserRole role, {int? parentId, int points = 0}) => User(
  id: id,
  name: name,
  phone: '90000000$id',
  role: role,
  isActive: true,
  points: points,
  createdAt: DateTime(2024),
  parentId: parentId,
);

PointTransaction tx(String description, int points, {PointStatus status = PointStatus.completed}) => PointTransaction(
  date: DateTime(2026, 9, 1),
  description: description,
  points: points,
  type: points < 0 ? PointTransType.spend : PointTransType.earn,
  status: status,
);

class _FakeSession extends SessionController {
  _FakeSession(this.me);

  final User me;

  @override
  Future<User?> build() async => me;
}

class _FakePoints implements PointsService {
  /// Whose history was asked for, in order, and whether the pending and failed ones were asked for too.
  final asked = <int>[];
  final askedIncomplete = <bool>[];

  final histories = <int, List<PointTransaction>>{};

  /// (member, points, reason) of each allocation and reclaim made.
  final allocated = <(int, int, String)>[];
  final reclaimed = <(int, int, String)>[];

  @override
  Future<int> allocate(int userId, int points, String reason) async {
    allocated.add((userId, points, reason));
    return points;
  }

  @override
  Future<int> reclaim(int userId, int points, String reason) async {
    reclaimed.add((userId, points, reason));
    return points;
  }

  @override
  Future<PagedResult<PointTransaction>> getHistory(
    int userId, {
    bool includeIncompleteAlso = false,
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    asked.add(userId);
    askedIncomplete.add(includeIncompleteAlso);
    // Like the server: completed ones only, unless the rest were asked for.
    final items = [
      for (final t in histories[userId] ?? const <PointTransaction>[])
        if (includeIncompleteAlso || t.status == PointStatus.completed) t,
    ];
    return PagedResult(items: items, totalCount: items.length, pageIndex: 1, pageSize: pageSize);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUsers implements UserService {
  _FakeUsers(this.users);

  final List<User> users;

  @override
  Future<PagedResult<User>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy}) async =>
      PagedResult(items: users, totalCount: users.length, pageIndex: 1, pageSize: pageSize);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A network: [me] with two members of their own, and a member of one of those.
({User me, User anu, User ravi, User deep, List<User> all}) network(UserRole myRole) {
  final me = member(1, 'Me', myRole, points: 40);
  final anu = member(2, 'Anu', UserRole.retailer, parentId: 1, points: 10);
  final ravi = member(3, 'Ravi', UserRole.user, parentId: 1, points: 5);
  final deep = member(4, 'Deep', UserRole.user, parentId: 2, points: 1);
  return (me: me, anu: anu, ravi: ravi, deep: deep, all: [me, anu, ravi, deep]);
}

Future<_FakePoints> pump(WidgetTester tester, UserRole myRole) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final net = network(myRole);
  final points = _FakePoints()
    ..histories[1] = [
      tx('My own entry', 7),
      tx('My held card', -1, status: PointStatus.pending),
      tx('My broken move', 4, status: PointStatus.failed),
    ]
    ..histories[2] = [tx('Anu entry', 3)]
    ..histories[3] = [tx('Ravi entry', -2)];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionControllerProvider.overrideWith(() => _FakeSession(net.me)),
        pointsServiceProvider.overrideWithValue(points),
        userServiceProvider.overrideWithValue(_FakeUsers(net.all)),
      ],
      child: const MaterialApp(home: PointsScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return points;
}

Future<void> choose(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(DropdownButtonFormField<int>, 'User'));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining(label).last);
  await tester.pumpAndSettle();
}

void main() {
  for (final role in [UserRole.superAdmin, UserRole.distributor, UserRole.retailer]) {
    group('${role.label}: the point details follow the member picked', () {
      testWidgets('open on my own point details', (tester) async {
        final points = await pump(tester, role);

        expect(find.text('My point details'), findsOneWidget);
        expect(find.text('40 pt balance'), findsOneWidget);
        expect(find.text('My own entry'), findsOneWidget);
        expect(points.asked, [1]);
      });

      testWidgets('picking a member shows their point details instead', (tester) async {
        await pump(tester, role);

        await choose(tester, 'Anu');

        expect(find.text('Point details of Anu'), findsOneWidget);
        expect(find.textContaining('10 pt balance'), findsOneWidget);
        expect(find.text('Anu entry'), findsOneWidget);
        expect(find.text('My own entry'), findsNothing);
      });

      testWidgets('picking another member switches to theirs', (tester) async {
        await pump(tester, role);
        await choose(tester, 'Anu');

        await choose(tester, 'Ravi');

        expect(find.text('Point details of Ravi'), findsOneWidget);
        expect(find.text('Ravi entry'), findsOneWidget);
        expect(find.text('Anu entry'), findsNothing);
      });

      testWidgets('picking myself shows my own point details again', (tester) async {
        await pump(tester, role);
        await choose(tester, 'Anu');
        expect(find.text('Anu entry'), findsOneWidget);

        await choose(tester, '(You)');

        expect(find.text('My point details'), findsOneWidget);
        expect(find.text('My own entry'), findsOneWidget);
        expect(find.text('Anu entry'), findsNothing);
      });

      testWidgets('a member with no transactions says so', (tester) async {
        final points = await pump(tester, role);
        points.histories[2] = const [];
        await choose(tester, 'Anu');

        // (The cached history of the first pick is fresh here: nothing was loaded for Anu before.)
        expect(find.text('No point transactions yet.'), findsOneWidget);
      });
    });
  }

  testWidgets('only me and my own members are in the drop-down, not deeper members', (tester) async {
    await pump(tester, UserRole.distributor);

    await tester.tap(find.widgetWithText(DropdownButtonFormField<int>, 'User'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Me (You)'), findsWidgets);
    expect(find.textContaining('Anu'), findsWidgets);
    expect(find.textContaining('Ravi'), findsWidgets);
    expect(find.textContaining('Deep'), findsNothing);
  });

  testWidgets('a User has no member picker and only ever sees their own details', (tester) async {
    final points = await pump(tester, UserRole.user);

    expect(find.widgetWithText(DropdownButtonFormField<int>, 'User'), findsNothing);
    expect(find.text('My point details'), findsNothing); // the header belongs to the member screens
    expect(find.text('My own entry'), findsOneWidget);
    expect(points.asked, [1]);
  });

  group('reclaiming and the reason', () {
    Finder field(String label) => find.widgetWithText(TextField, label);

    testWidgets('only a Super Admin is offered Reclaim', (tester) async {
      await pump(tester, UserRole.superAdmin);
      expect(find.text('Reclaim'), findsOneWidget);
      expect(find.text('Allocate / Reclaim points'), findsOneWidget);
    });

    for (final role in [UserRole.distributor, UserRole.retailer]) {
      testWidgets('a ${role.label} has no Reclaim button, only Allocate', (tester) async {
        await pump(tester, role);
        await choose(tester, 'Anu');

        expect(find.text('Reclaim'), findsNothing);
        expect(find.text('Allocate'), findsOneWidget);
        expect(find.text('Allocate points'), findsOneWidget);
        expect(find.text('Allocate / Reclaim points'), findsNothing);
      });
    }

    testWidgets('allocating needs a reason: without one nothing is sent and the field says so', (tester) async {
      final points = await pump(tester, UserRole.distributor);
      await choose(tester, 'Anu');
      await tester.enterText(field('Points'), '5');

      await tester.tap(find.text('Allocate'));
      await tester.pumpAndSettle();

      expect(points.allocated, isEmpty);
      expect(find.text('Enter a reason.'), findsOneWidget);
    });

    testWidgets('a reason of only spaces does not count', (tester) async {
      final points = await pump(tester, UserRole.distributor);
      await choose(tester, 'Anu');
      await tester.enterText(field('Points'), '5');
      await tester.enterText(field('Reason (required)'), '   ');

      await tester.tap(find.text('Allocate'));
      await tester.pumpAndSettle();

      expect(points.allocated, isEmpty);
      expect(find.text('Enter a reason.'), findsOneWidget);
    });

    testWidgets('with a reason it is allocated, with the reason trimmed', (tester) async {
      final points = await pump(tester, UserRole.distributor);
      await choose(tester, 'Anu');
      await tester.enterText(field('Points'), '5');
      await tester.enterText(field('Reason (required)'), '  Festival offer ');

      await tester.tap(find.text('Allocate'));
      await tester.pumpAndSettle();

      expect(points.allocated, [(2, 5, 'Festival offer')]);
      expect(find.text('Enter a reason.'), findsNothing);
      expect(find.text('Points allocated.'), findsOneWidget);
    });

    testWidgets('both a missing amount and a missing reason are pointed out together', (tester) async {
      final points = await pump(tester, UserRole.superAdmin);
      await choose(tester, 'Anu');

      await tester.tap(find.text('Allocate'));
      await tester.pumpAndSettle();

      expect(points.allocated, isEmpty);
      expect(find.text('Enter a positive number of points.'), findsOneWidget);
      expect(find.text('Enter a reason.'), findsOneWidget);
    });

    testWidgets('a Super Admin reclaim needs a reason too', (tester) async {
      final points = await pump(tester, UserRole.superAdmin);
      await choose(tester, 'Anu');
      await tester.enterText(field('Points'), '3');

      await tester.tap(find.text('Reclaim'));
      await tester.pumpAndSettle();
      expect(points.reclaimed, isEmpty);
      expect(find.text('Enter a reason.'), findsOneWidget);

      await tester.enterText(field('Reason (required)'), 'Wrong allocation');
      await tester.tap(find.text('Reclaim'));
      await tester.pumpAndSettle();
      expect(points.reclaimed, [(2, 3, 'Wrong allocation')]);
    });

    testWidgets('a Super Admin top-up may leave the reason out', (tester) async {
      final points = await pump(tester, UserRole.superAdmin);
      await choose(tester, '(You)');
      await tester.enterText(field('Points'), '100');

      expect(find.text('Reason (optional)'), findsOneWidget);
      await tester.tap(find.text('Add to my balance'));
      await tester.pumpAndSettle();

      expect(points.allocated, [(1, 100, '')]);
      expect(find.text('Enter a reason.'), findsNothing);
    });

    testWidgets('the reason field is marked required for an allocation', (tester) async {
      await pump(tester, UserRole.retailer);
      await choose(tester, 'Ravi');

      expect(find.text('Reason (required)'), findsOneWidget);
    });
  });

  testWidgets('the points figures are set larger than the rest of the list text', (tester) async {
    await pump(tester, UserRole.distributor);

    double sizeOf(String text) => tester.widget<Text>(find.text(text)).style?.fontSize ?? 0;
    // Resolve the description and date sizes as they are actually drawn.
    double drawn(String text) {
      final element = tester.element(find.text(text));
      final style = DefaultTextStyle.of(element).style.merge(tester.widget<Text>(find.text(text)).style);
      return style.fontSize ?? 14;
    }

    final points = sizeOf('+7');
    expect(points, pointsFontSize);
    expect(points, greaterThan(drawn('My own entry') + 3));
    expect(points, greaterThan(sizeOf('+7') - 1)); // sanity
    expect(find.text('+7'), findsOneWidget);
  });

  group('completed only, with a switch for a Super Admin', () {
    Finder theSwitch() => find.widgetWithText(SwitchListTile, 'Show pending and failed transactions');

    testWidgets('the list shows only completed transactions by default', (tester) async {
      final points = await pump(tester, UserRole.superAdmin);

      expect(find.text('My own entry'), findsOneWidget);
      expect(find.text('My held card'), findsNothing);
      expect(find.text('My broken move'), findsNothing);
      expect(find.text('Pending'), findsNothing);
      expect(points.askedIncomplete, [false]);
    });

    testWidgets('a Super Admin has the switch, off at first', (tester) async {
      await pump(tester, UserRole.superAdmin);

      expect(theSwitch(), findsOneWidget);
      expect(tester.widget<SwitchListTile>(theSwitch()).value, isFalse);
    });

    testWidgets('switching it on lists the pending and failed ones, marked, and off hides them again', (tester) async {
      final points = await pump(tester, UserRole.superAdmin);

      await tester.tap(theSwitch());
      await tester.pumpAndSettle();

      expect(find.text('My own entry'), findsOneWidget);
      expect(find.text('My held card'), findsOneWidget);
      expect(find.text('My broken move'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(points.askedIncomplete.last, isTrue);

      await tester.tap(theSwitch());
      await tester.pumpAndSettle();

      expect(find.text('My held card'), findsNothing);
      expect(find.text('Failed'), findsNothing);
    });

    testWidgets('the switch applies to whichever member is picked', (tester) async {
      final points = await pump(tester, UserRole.superAdmin);
      points.histories[2] = [tx('Anu entry', 3), tx('Anu held', 3, status: PointStatus.pending)];
      await tester.tap(theSwitch());
      await tester.pumpAndSettle();

      await choose(tester, 'Anu');

      expect(find.text('Anu entry'), findsOneWidget);
      expect(find.text('Anu held'), findsOneWidget);
      expect(points.askedIncomplete.last, isTrue);
    });

    for (final role in [UserRole.distributor, UserRole.retailer, UserRole.user]) {
      testWidgets('a ${role.label} has no switch and only ever asks for completed ones', (tester) async {
        final points = await pump(tester, role);

        expect(theSwitch(), findsNothing);
        expect(find.text('My own entry'), findsOneWidget);
        expect(find.text('My held card'), findsNothing);
        expect(points.askedIncomplete.every((asked) => asked == false), isTrue);
      });
    }
  });
}
