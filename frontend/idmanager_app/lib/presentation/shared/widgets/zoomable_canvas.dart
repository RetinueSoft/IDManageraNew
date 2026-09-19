import 'package:flutter/material.dart';

/// A pan/zoom area for a fixed-size [child] (the card): it opens **fitted** to the
/// available space and has zoom in / zoom out / fit buttons, so the whole card can always
/// be brought fully into view. Panning is unrestricted and the mouse wheel / pinch zoom
/// around the pointer.
///
/// The zoom is purely a view transform: [child] is laid out at [contentSize] in its own
/// units, so anything positioned in millimeters inside it is unaffected by zoom.
class ZoomableCanvas extends StatefulWidget {
  const ZoomableCanvas({super.key, required this.contentSize, required this.child});

  /// The child's own size (e.g. the card in screen pixels at 100%).
  final Size contentSize;
  final Widget child;

  @override
  State<ZoomableCanvas> createState() => _ZoomableCanvasState();
}

class _ZoomableCanvasState extends State<ZoomableCanvas> {
  static const double _minScale = 0.1;
  static const double _maxScale = 10;
  static const double _stepFactor = 1.25;
  static const double _fitPadding = 24;

  final _controller = TransformationController();
  Size _viewport = Size.zero;
  bool _needsFit = true;

  @override
  void didUpdateWidget(ZoomableCanvas old) {
    super.didUpdateWidget(old);
    // A different card size (e.g. after editing the template) starts fitted again.
    if (old.contentSize != widget.contentSize) _needsFit = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The horizontal scale (uniform, no rotation). Not getMaxScaleOnAxis(): that includes the
  // depth axis, which is always 1, so it would report 1 for every scale below 1.
  double get _scale => _controller.value.entry(0, 0);

  void _fit() {
    if (_viewport.isEmpty || widget.contentSize.isEmpty) return;
    final content = widget.contentSize;
    final fit = ((_viewport.width - 2 * _fitPadding) / content.width)
        .clamp(0.0, double.infinity)
        .toDouble();
    final fitH = ((_viewport.height - 2 * _fitPadding) / content.height)
        .clamp(0.0, double.infinity)
        .toDouble();
    final scale = (fit < fitH ? fit : fitH).clamp(_minScale, _maxScale).toDouble();
    final dx = (_viewport.width - content.width * scale) / 2;
    final dy = (_viewport.height - content.height * scale) / 2;
    _controller.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  /// Zooms by [factor] around the centre of the visible area.
  void _zoomBy(double factor) {
    final target = (_scale * factor).clamp(_minScale, _maxScale).toDouble();
    final applied = target / _scale;
    final c = Offset(_viewport.width / 2, _viewport.height / 2);
    final zoom = Matrix4.identity()
      ..translateByDouble(c.dx, c.dy, 0, 1)
      ..scaleByDouble(applied, applied, 1, 1)
      ..translateByDouble(-c.dx, -c.dy, 0, 1);
    _controller.value = zoom * _controller.value;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.biggest != _viewport) {
          _viewport = box.biggest;
          _needsFit = true; // the window was resized: refit
        }
        if (_needsFit) {
          _needsFit = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fit();
          });
        }

        return Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _controller,
                constrained: false,
                minScale: _minScale,
                maxScale: _maxScale,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                child: SizedBox.fromSize(size: widget.contentSize, child: widget.child),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Zoom out',
                      icon: const Icon(Icons.remove),
                      onPressed: () => _zoomBy(1 / _stepFactor),
                    ),
                    IconButton(
                      tooltip: 'Fit to window',
                      icon: const Icon(Icons.fit_screen),
                      onPressed: _fit,
                    ),
                    IconButton(
                      tooltip: 'Zoom in',
                      icon: const Icon(Icons.add),
                      onPressed: () => _zoomBy(_stepFactor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
