/// Points credited to and debited from the member in one calendar month.
class MonthlyPoints {
  const MonthlyPoints({
    required this.year,
    required this.month,
    required this.credit,
    required this.debit,
  });

  final int year;

  /// 1-12.
  final int month;
  final int credit;
  final int debit;
}

/// The members counted by role (a Super Admin is never counted as a member).
class MemberRoleCounts {
  const MemberRoleCounts({
    required this.distributors,
    required this.retailers,
    required this.users,
  });

  final int distributors;
  final int retailers;
  final int users;

  int get total => distributors + retailers + users;
}

/// What the dashboard shows the signed-in member.
class DashboardSummary {
  const DashboardSummary({
    required this.balance,
    required this.creditThisMonth,
    required this.debitThisMonth,
    required this.creditTotal,
    required this.debitTotal,
    required this.cardsThisMonth,
    required this.cardsTotal,
    required this.membersCount,
    required this.months,
    this.membersByRole,
  });

  final int balance;
  final int creditThisMonth;
  final int debitThisMonth;
  final int creditTotal;
  final int debitTotal;
  final int cardsThisMonth;
  final int cardsTotal;

  /// How many members they can see (not counting themselves); null when they have no member screens.
  final int? membersCount;

  /// The same members by role; null when [membersCount] is.
  final MemberRoleCounts? membersByRole;

  /// The last twelve months, oldest first.
  final List<MonthlyPoints> months;
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Sep" for a month of the current year, "Sep 25" when it belongs to another - so a 12 month graph
/// reads unambiguously across a year end.
String monthLabel(MonthlyPoints m, {required int currentYear}) {
  final name = _monthNames[(m.month - 1).clamp(0, 11)];
  return m.year == currentYear
      ? name
      : "$name ${(m.year % 100).toString().padLeft(2, '0')}";
}
