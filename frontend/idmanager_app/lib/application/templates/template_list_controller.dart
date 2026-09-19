import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/templates/domain/card_template.dart';

part 'template_list_controller.g.dart';

@riverpod
class TemplateListController extends _$TemplateListController {
  @override
  Future<List<CardTemplate>> build() async {
    final page = await ref.watch(templateServiceProvider).getAll(pageSize: 200);
    return page.items;
  }
}
