library interactive_slider;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider_controller.dart';
import 'package:interactive_slider/interactive_slider_painter.dart';

export 'package:interactive_slider/interactive_slider_controller.dart';

class InteractiveSlider extends StatefulWidget {
  const InteractiveSlider({
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.unfocusedMargin = const EdgeInsets.symmetric(horizontal: 16),
    this.focusedMargin = EdgeInsets.zero,
    this.startIcon,
    this.centerIcon,
    this.endIcon,
    this.transitionDuration = const Duration(milliseconds: 750),
    this.transitionCurve = const ElasticOutCurve(0.8),
    this.backgroundColor,
    this.foregroundColor,
    this.shapeBorder = const StadiumBorder(),
    this.unfocusedHeight = 10.0,
    this.focusedHeight = 20.0,
    this.unfocusedOpacity = 0.4,
    this.initialProgress = 0.0,
    this.onChanged,
    this.iconGap = 8.0,
    this.iconCrossAxisAlignment = CrossAxisAlignment.center,
    this.style,
    this.controller,
    this.iconColor,
    this.min = 0.0,
    this.max = 1.0,
    this.brightness,
  });

  final EdgeInsets padding;
  final EdgeInsets unfocusedMargin;
  final EdgeInsets focusedMargin;
  final Widget? startIcon;
  final Widget? centerIcon;
  final Widget? endIcon;
  final Duration transitionDuration;
  final Curve transitionCurve;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final ShapeBorder shapeBorder;
  final double unfocusedHeight;
  final double focusedHeight;
  final double unfocusedOpacity;
  final double initialProgress;
  final ValueChanged<double>? onChanged;
  final double iconGap;
  final CrossAxisAlignment iconCrossAxisAlignment;
  final TextStyle? style;
  final InteractiveSliderController? controller;
  final Color? iconColor;
  final double min;
  final double max;
  final Brightness? brightness;

  @override
  State<InteractiveSlider> createState() => _InteractiveSliderState();
}

class _InteractiveSliderState extends State<InteractiveSlider> {
  late final _height = ValueNotifier(widget.unfocusedHeight);
  late final _opacity = ValueNotifier(widget.unfocusedOpacity);
  late final _margin = ValueNotifier(widget.unfocusedMargin);
  late final _progress = widget.controller ?? ValueNotifier(widget.initialProgress);

  @override
  void initState() {
    super.initState();
    _progress.addListener(_onChanged);
  }

  @override
  void dispose() {
    _height.dispose();
    _opacity.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = widget.brightness ?? (theme.brightness == Brightness.light ? Brightness.dark : Brightness.light);
    final brightnessColor = brightness == Brightness.light ? Colors.white : Colors.black;
    Widget slider = ValueListenableBuilder<double>(
      valueListenable: _height,
      builder: (context, height, child) {
        return AnimatedContainer(
          clipBehavior: Clip.antiAlias,
          width: double.infinity,
          height: _height.value,
          duration: widget.transitionDuration,
          curve: widget.transitionCurve,
          decoration: ShapeDecoration(
            shape: widget.shapeBorder,
            color: widget.backgroundColor ?? brightnessColor.withOpacity(0.12),
          ),
          child: child,
        );
      },
      child: ValueListenableBuilder<double>(
        valueListenable: _opacity,
        builder: _opacityBuilder,
        child: CustomPaint(
          painter: InteractiveSliderPainter(
            progress: _progress,
            color: widget.foregroundColor ?? brightnessColor,
          ),
        ),
      ),
    );
    if (widget.startIcon != null || widget.centerIcon != null || widget.endIcon != null) {
      slider = IconTheme(
        data: theme.iconTheme.copyWith(color: widget.iconColor ?? widget.foregroundColor ?? brightnessColor),
        child: DefaultTextStyle(
          style: (widget.style ?? theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
            color: widget.foregroundColor ?? brightnessColor,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: widget.iconGap),
                child: slider,
              ),
              Row(
                crossAxisAlignment: widget.iconCrossAxisAlignment,
                children: [
                  if (widget.startIcon case var startIcon?)
                    ValueListenableBuilder<double>(
                      valueListenable: _opacity,
                      builder: _opacityBuilder,
                      child: startIcon,
                    )
                  else if (widget.endIcon case var endIcon?)
                    Visibility.maintain(visible: false, child: endIcon),
                  const Spacer(),
                  if (widget.centerIcon case var centerIcon?) centerIcon,
                  const Spacer(),
                  if (widget.endIcon case var endIcon?)
                    ValueListenableBuilder<double>(
                      valueListenable: _opacity,
                      builder: _opacityBuilder,
                      child: endIcon,
                    )
                  else if (widget.startIcon case var startIcon?)
                    Visibility.maintain(visible: false, child: startIcon),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (details) {
          if (!mounted) return;
          _height.value = widget.focusedHeight;
          _opacity.value = 1.0;
          _margin.value = widget.focusedMargin;
        },
        onHorizontalDragEnd: (details) {
          if (!mounted) return;
          _height.value = widget.unfocusedHeight;
          _opacity.value = widget.unfocusedOpacity;
          _margin.value = widget.unfocusedMargin;
        },
        onHorizontalDragUpdate: (details) {
          if (!mounted) return;
          final renderBox = context.findRenderObject() as RenderBox;
          final sliderWidth = renderBox.size.width - widget.padding.horizontal;
          _progress.value = (_progress.value + (details.delta.dx / sliderWidth)).clamp(0.0, 1.0);
        },
        child: ValueListenableBuilder<EdgeInsets>(
          valueListenable: _margin,
          child: slider,
          builder: (context, margin, child) {
            return AnimatedPadding(
              duration: widget.transitionDuration,
              curve: widget.transitionCurve,
              padding: margin,
              child: child,
            );
          },
        ),
      ),
    );
  }

  Widget _opacityBuilder(BuildContext context, double opacity, Widget? child) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: widget.transitionDuration,
      curve: widget.transitionCurve,
      child: child,
    );
  }

  void _onChanged() => widget.onChanged?.call(lerpDouble(widget.min, widget.max, _progress.value) ?? _progress.value);
}
