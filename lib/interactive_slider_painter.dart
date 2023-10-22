import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider.dart';

class InteractiveSliderPainter extends CustomPainter {
  InteractiveSliderPainter({
    required this.progress,
    required Color color,
    this.gradient,
    required this.gradientSize,
  })  : _paint = Paint()..color = color,
        super(repaint: progress);

  final ValueNotifier<double> progress;
  final Gradient? gradient;
  final GradientSize gradientSize;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final progressRect =
        Rect.fromLTWH(0, 0, progress.value * size.width, size.height);
    if (gradient case var gradient?) {
      final sizeRect = switch (gradientSize) {
        GradientSize.totalWidth => Rect.fromLTWH(0, 0, size.width, size.height),
        GradientSize.progressWidth => progressRect,
      };
      _paint.shader = gradient.createShader(sizeRect);
    }
    canvas.drawRect(progressRect, _paint);
  }

  @override
  bool shouldRepaint(InteractiveSliderPainter oldDelegate) =>
      progress.value != oldDelegate.progress.value ||
      _paint.color != oldDelegate._paint.color;
}
