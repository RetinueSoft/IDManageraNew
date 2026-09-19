import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/templates/template_list_controller.dart';
import '../../core_engine/templates/domain/card_template.dart';
import '../routing/app_routes.dart';

class TemplateListScreen extends ConsumerWidget {
  const TemplateListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templateListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New template',
            onPressed: () => context.go(AppRoutes.templateNew()),
          ),
        ],
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load templates: $e')),
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(child: Text('No templates yet. Tap + to create one.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: templates.length,
            itemBuilder: (context, index) => _TemplateCard(template: templates[index]),
          );
        },
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template});

  final CardTemplate template;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(AppRoutes.templateDesign(template.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: template.frontImageBase64.isNotEmpty
                  ? Image.memory(base64Decode(template.frontImageBase64), fit: BoxFit.cover)
                  : const ColoredBox(color: Colors.black12, child: Icon(Icons.credit_card)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(template.name, style: Theme.of(context).textTheme.titleSmall),
                        Text('${template.pointCost} pt · ${template.isActive ? "Active" : "Inactive"}'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit details',
                    onPressed: () => context.go(AppRoutes.templateEdit(template.id)),
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
