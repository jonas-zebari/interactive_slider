import 'package:flutter/material.dart';

class InteractiveSliderPainter extends CustomPainter {
  InteractiveSliderPainter({
    required this.progress,
    required Color color,
  })  : _paint = Paint()..color = color,
        super(repaint: progress);

  final ValueNotifier<double> progress;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final progressRect = Rect.fromLTWH(0, 0, progress.value * size.width, size.height);
    canvas.drawRect(progressRect, _paint);
  }

  @override
  bool shouldRepaint(InteractiveSliderPainter oldDelegate) {
    return progress.value != oldDelegate.progress.value || _paint != oldDelegate._paint;
  }
}
