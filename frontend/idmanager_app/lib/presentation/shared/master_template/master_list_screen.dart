import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';
import '../widgets/status_chip.dart';

/// Generic list screen chrome: search, add, and an empty state, shared by every
/// master list (Templates, Users, Audit Log, ...) instead of each rebuilding its
/// own list scaffold.
class MasterListScreen<T> extends StatefulWidget {
  const MasterListScreen({
    super.key,
    required this.title,
    required this.items,
    required this.primaryText,
    required this.secondaryText,
    required this.isActive,
    required this.matchesSearch,
    required this.onOpen,
    required this.emptyStateMessage,
    this.onAdd,
    this.isLoading = false,
  });

  final String title;
  final List<T> items;
  final String Function(T item) primaryText;
  final String Function(T item) secondaryText;
  final bool Function(T item) isActive;
  final bool Function(T item, String query) matchesSearch;
  final void Function(BuildContext context, T item) onOpen;
  final String emptyStateMessage;
  final VoidCallback? onAdd;
  final bool isLoading;

  @override
  State<MasterListScreen<T>> createState() => _MasterListScreenState<T>();
}

class _MasterListScreenState<T> extends State<MasterListScreen<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.items
        : widget.items.where((item) => widget.matchesSearch(item, _query)).toList();

    final emptyMessage = _query.isNotEmpty
        ? 'No ${widget.title.toLowerCase()} match this search.'
        : widget.emptyStateMessage;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.onAdd != null)
            IconButton(icon: const Icon(Icons.add), tooltip: 'Add', onPressed: widget.onAdd),
        ],
      ),
      floatingActionButton: widget.onAdd == null
          ? null
          : FloatingActionButton(
              heroTag: 'master-list-fab-${widget.title}',
              onPressed: widget.onAdd,
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Search', suffixIcon: Icon(Icons.search)),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? EmptyState(
                    message: emptyMessage,
                    actionLabel: widget.onAdd == null ? null : 'Add',
                    onAction: widget.onAdd,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          title: Text(widget.primaryText(item)),
                          subtitle: Text(widget.secondaryText(item)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatusChip(isActive: widget.isActive(item)),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () => widget.onOpen(context, item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
