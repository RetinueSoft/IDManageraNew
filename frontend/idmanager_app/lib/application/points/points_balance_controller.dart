import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';

part 'points_balance_controller.g.dart';

@riverpod
Future<int> pointsBalance(Ref ref) => ref.watch(pointsServiceProvider).getBalance();
