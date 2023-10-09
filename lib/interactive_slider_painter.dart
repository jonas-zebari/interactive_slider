import 'package:flutter/material.dart';

class InteractiveSliderPainter extends CustomPainter {
  InteractiveSliderPainter({
    required this.direction,
    required this.progress,
    required Color color,
  })  : _paint = Paint()..color = color,
        super(repaint: progress);

  final Axis direction;
  final ValueNotifier<double> progress;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final progressRect = switch (direction) {
      Axis.horizontal =>
        Rect.fromLTWH(0, 0, progress.value * size.width, size.height),
      Axis.vertical => Rect.fromLTWH(
          0,
          (1 - progress.value) * size.height,
          size.width,
          size.height,
        ),
    };
    canvas.drawRect(progressRect, _paint);
  }

  @override
  bool shouldRepaint(InteractiveSliderPainter oldDelegate) =>
      progress.value != oldDelegate.progress.value ||
      _paint.color != oldDelegate._paint.color;
}
