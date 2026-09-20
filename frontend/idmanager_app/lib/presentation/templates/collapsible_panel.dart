import 'package:flutter/material.dart';

/// Which side of the screen a panel is docked to; the shrink button points toward it. A bottom
/// panel has a [CollapsiblePanel.height] (its width fills the space it is given).
enum CollapseEdge { left, right, bottom }

/// A side panel of the designer that can be shrunk to a thin strip (giving the card more room)
/// and expanded again. The panel's content stays mounted while shrunk, so nothing typed or
/// selected inside it is lost.
class CollapsiblePanel extends StatefulWidget {
  const CollapsiblePanel({
    super.key,
    required this.title,
    this.width = 260,
    this.height = 300,
    required this.edge,
    required this.child,
    this.initiallyCollapsed = false,
  });

  final String title;
  final double width;
  final double height;
  final CollapseEdge edge;
  final Widget child;
  final bool initiallyCollapsed;

  static const double collapsedWidth = 40;
  static const double collapsedHeight = 40;

  @override
  State<CollapsiblePanel> createState() => _CollapsiblePanelState();
}

class _CollapsiblePanelState extends State<CollapsiblePanel> {
  late bool _collapsed = widget.initiallyCollapsed;
  late double _height = widget.height;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    if (widget.edge == CollapseEdge.bottom) return _buildBottom(context);
    final towardsEdge = widget.edge == CollapseEdge.left
        ? Icons.chevron_left
        : Icons.chevron_right;
    final awayFromEdge = widget.edge == CollapseEdge.left
        ? Icons.chevron_right
        : Icons.chevron_left;

    final button = IconButton(
      tooltip: _collapsed ? 'Expand ${widget.title}' : 'Shrink ${widget.title}',
      icon: Icon(_collapsed ? awayFromEdge : towardsEdge),
      visualDensity: VisualDensity.compact,
      onPressed: () => setState(() => _collapsed = !_collapsed),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: _collapsed ? CollapsiblePanel.collapsedWidth : widget.width,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      // The content stays mounted (just hidden) while shrunk, so nothing typed is lost.
      child: Stack(
        children: [
          Offstage(
            offstage: _collapsed,
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: widget.width,
              maxWidth: widget.width,
              child: SizedBox(
                width: widget.width,
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (widget.edge == CollapseEdge.right) button,
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              widget.title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                        if (widget.edge == CollapseEdge.left) button,
                      ],
                    ),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ),
          ),
          if (_collapsed)
            Column(
              children: [
                button,
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    final button = IconButton(
      tooltip: _collapsed ? 'Expand ${widget.title}' : 'Shrink ${widget.title}',
      icon: Icon(_collapsed ? Icons.expand_less : Icons.expand_more),
      visualDensity: VisualDensity.compact,
      onPressed: () => setState(() => _collapsed = !_collapsed),
    );
    final header = Row(
      children: [
        button,
        Text(widget.title, style: Theme.of(context).textTheme.titleSmall),
      ],
    );

    final height = _height;
    final panel = AnimatedContainer(
      key: const Key('panel-body'),
      duration: _dragging ? Duration.zero : const Duration(milliseconds: 150),
      height: _collapsed ? CollapsiblePanel.collapsedHeight : height,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: Stack(
        children: [
          Offstage(
            offstage: _collapsed,
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minHeight: height,
              maxHeight: height,
              child: SizedBox(
                height: height,
                child: Column(
                  children: [
                    header,
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ),
          ),
          if (_collapsed) header,
        ],
      ),
    );
    // Drag the bar on the panel's top edge to make it taller or shorter.
    final maxHeight = (MediaQuery.sizeOf(context).height - 200).clamp(
      200.0,
      2000.0,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_collapsed)
          MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: GestureDetector(
              key: const Key('resize-handle'),
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => setState(() => _dragging = true),
              onVerticalDragUpdate: (d) => setState(
                () => _height = (_height - d.delta.dy).clamp(150.0, maxHeight),
              ),
              onVerticalDragEnd: (_) => setState(() => _dragging = false),
              child: Container(
                height: 8,
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.outlineVariant,
                child: Container(
                  width: 40,
                  height: 3,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
        panel,
      ],
    );
  }
}
