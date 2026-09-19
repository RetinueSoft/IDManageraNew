import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/security/domain/user.dart';

part 'user_list_controller.g.dart';

@riverpod
class UserListController extends _$UserListController {
  @override
  Future<List<User>> build() async {
    final page = await ref.watch(userServiceProvider).getAll(pageSize: 200);
    return page.items;
  }
}
