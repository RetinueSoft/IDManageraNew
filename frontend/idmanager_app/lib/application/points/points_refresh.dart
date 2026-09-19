import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../security/session_controller.dart';
import '../security/user_list_controller.dart';
import 'points_balance_controller.dart';
import 'points_history_controller.dart';

/// Refreshes everything on screen that shows points. Call it after anything that moves
/// points (allocating / reclaiming, generating or downloading a card): the caller's own
/// history and balance change too, not only the other member's, and the members' point
/// totals in the Users list.
void refreshPointsData(Ref ref, {int? alsoUserId}) {
  final myId = ref.read(sessionControllerProvider).value?.id;
  if (myId != null) ref.invalidate(pointsHistoryControllerProvider(myId));
  if (alsoUserId != null) ref.invalidate(pointsHistoryControllerProvider(alsoUserId));
  ref.invalidate(pointsBalanceProvider);
  ref.invalidate(userListControllerProvider);
}
