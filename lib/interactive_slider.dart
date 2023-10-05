library interactive_slider;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider_controller.dart';
import 'package:interactive_slider/interactive_slider_painter.dart';

export 'package:interactive_slider/interactive_slider_controller.dart';

enum IconPosition {
  below,
  inline,
}

class InteractiveSlider extends StatefulWidget {
  static const defaultTransitionPeriod = 0.8;
  static const easeTransitionPeriod = 2.0;

  const InteractiveSlider({
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.unfocusedMargin = const EdgeInsets.symmetric(horizontal: 16),
    this.focusedMargin = EdgeInsets.zero,
    this.startIcon,
    this.centerIcon,
    this.endIcon,
    this.transitionDuration = const Duration(milliseconds: 750),
    this.transitionCurvePeriod = InteractiveSlider.defaultTransitionPeriod,
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
    this.iconPosition = IconPosition.inline,
    this.iconSize = 22.0,
  })  : assert(transitionCurvePeriod > 0.0),
        assert(transitionCurvePeriod <= 2.0);

  /// Static outer padding for the entire widget
  final EdgeInsets padding;

  /// Inset for when the user is not interacting with the slider
  final EdgeInsets unfocusedMargin;

  /// Inset for when the user is interacting with the slider
  final EdgeInsets focusedMargin;

  /// Icon to display under the slider bar in the start position
  final Widget? startIcon;

  /// Icon to display under the slider bar in the center position
  final Widget? centerIcon;

  /// Icon to display under the slider bar in the end position
  final Widget? endIcon;

  /// Duration for transition animations (size, height, opacity)
  final Duration transitionDuration;

  /// Period for elastic animation curve (size, height, opacity)
  /// Can be any value greater than 0.0 and less than or equal to 2.0
  final double transitionCurvePeriod;

  /// Color to apply to all foreground elements (slider progress, icons,
  /// center text)
  final Color? foregroundColor;

  /// Color to apply to slider background
  final Color? backgroundColor;

  /// Shape for the slider progress
  final ShapeBorder shapeBorder;

  /// Slider height when the user is not interacting the slider
  final double unfocusedHeight;

  /// Slider height when the user is interacting with the slider
  final double focusedHeight;

  /// Slider progress and icon opacity when the user is not interacting with
  /// the slider
  final double unfocusedOpacity;

  /// The normalized value the slider should be set to when it is first built
  final double initialProgress;

  /// A callback that provides the transformed slider progress (if min and max
  /// are set)
  final ValueChanged<double>? onChanged;

  /// Distance between the start, center, and end icons and the slider
  final double iconGap;

  /// Start, center, and end icon row cross axis alignment
  final CrossAxisAlignment iconCrossAxisAlignment;

  /// Text style to be supplied to any text widgets in the start, end, or center
  /// icons
  final TextStyle? style;

  /// A controller for external manipulation of the slider
  final InteractiveSliderController? controller;

  /// Color to apply to any icons widgets in the start, end, or center icon
  /// positions
  final Color? iconColor;

  /// Transformed slider value minimum
  final double min;

  /// Transformed slider value maximum
  final double max;

  /// The brightness the slider and icon colors should be
  /// (light = white, dark = black)
  final Brightness? brightness;

  /// Determines the location of the icons if any are provided
  final IconPosition iconPosition;

  /// Icon size to apply to all icon children
  final double iconSize;

  @override
  State<InteractiveSlider> createState() => _InteractiveSliderState();
}

class _InteractiveSliderState extends State<InteractiveSlider> {
  late ElasticOutCurve _transitionCurve;
  late double _maxSizeFactor;
  late final _height = ValueNotifier(widget.unfocusedHeight);
  late final _opacity = ValueNotifier(widget.unfocusedOpacity);
  late final _margin = ValueNotifier(widget.unfocusedMargin);
  late final _progress =
      widget.controller ?? ValueNotifier(widget.initialProgress);

  @override
  void initState() {
    super.initState();
    _progress.addListener(_onChanged);
    _updateCurveInfo();
  }

  @override
  void didUpdateWidget(InteractiveSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCurveInfo();
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
    final brightness = widget.brightness ??
        (theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light);
    final brightnessColor =
        brightness == Brightness.light ? Colors.white : Colors.black;
    final textStyle =
        widget.style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    Widget slider = ValueListenableBuilder<double>(
      valueListenable: _height,
      builder: (context, height, child) {
        return AnimatedContainer(
          clipBehavior: Clip.antiAlias,
          width: double.infinity,
          height: _height.value,
          duration: widget.transitionDuration,
          curve: _transitionCurve,
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
    if (widget.startIcon != null ||
        widget.centerIcon != null ||
        widget.endIcon != null) {
      slider = IconTheme(
        data: theme.iconTheme.copyWith(
          color: widget.iconColor ?? widget.foregroundColor ?? brightnessColor,
          size: widget.iconSize,
        ),
        child: DefaultTextStyle(
          style: textStyle.copyWith(
            color: widget.foregroundColor ?? brightnessColor,
          ),
          child: Column(
            children: [
              switch (widget.iconPosition) {
                IconPosition.below => Padding(
                    padding: EdgeInsets.only(bottom: widget.iconGap),
                    child: slider,
                  ),
                IconPosition.inline => Row(
                    children: [
                      if (widget.startIcon case var startIcon?)
                        ValueListenableBuilder<double>(
                          valueListenable: _opacity,
                          builder: _opacityBuilder,
                          child: startIcon,
                        ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.iconGap,
                          ),
                          child: slider,
                        ),
                      ),
                      if (widget.endIcon case var endIcon?)
                        ValueListenableBuilder<double>(
                          valueListenable: _opacity,
                          builder: _opacityBuilder,
                          child: endIcon,
                        )
                    ],
                  ),
              },
              if (widget.iconPosition == IconPosition.below)
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility.maintain(
          visible: false,
          child: _Prototype(
            padding: widget.padding,
            height: widget.focusedHeight * _maxSizeFactor,
            iconGap: widget.iconGap,
            startIcon: widget.startIcon ?? const SizedBox.shrink(),
            centerIcon: widget.centerIcon ?? const SizedBox.shrink(),
            endIcon: widget.endIcon ?? const SizedBox.shrink(),
            iconPosition: widget.iconPosition,
          ),
        ),
        Padding(
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
              final sliderWidth =
                  renderBox.size.width - widget.padding.horizontal;
              _progress.value =
                  (_progress.value + (details.delta.dx / sliderWidth))
                      .clamp(0.0, 1.0);
            },
            child: ValueListenableBuilder<EdgeInsets>(
              valueListenable: _margin,
              child: slider,
              builder: (context, margin, child) {
                return AnimatedPadding(
                  duration: widget.transitionDuration,
                  curve: _transitionCurve,
                  padding: margin,
                  child: child,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _opacityBuilder(BuildContext context, double opacity, Widget? child) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: widget.transitionDuration,
      curve: _transitionCurve,
      child: child,
    );
  }

  void _onChanged() => widget.onChanged?.call(
      lerpDouble(widget.min, widget.max, _progress.value) ?? _progress.value);

  void _updateCurveInfo() {
    _transitionCurve = ElasticOutCurve(widget.transitionCurvePeriod);
    _maxSizeFactor =
        _transitionCurve.transform(widget.transitionCurvePeriod / 2);
  }
}

class _Prototype extends StatelessWidget {
  const _Prototype({
    required this.padding,
    required this.height,
    required this.iconGap,
    required this.startIcon,
    required this.centerIcon,
    required this.endIcon,
    required this.iconPosition,
  });

  final EdgeInsets padding;
  final double height;
  final double iconGap;
  final Widget startIcon;
  final Widget centerIcon;
  final Widget endIcon;
  final IconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    final sliderHeight =
        iconPosition == IconPosition.below ? height + iconGap : height;
    return Padding(
      padding: padding,
      child: Column(
        children: [
          SizedBox(height: sliderHeight),
          if (iconPosition == IconPosition.below)
            Row(
              children: [
                startIcon,
                centerIcon,
                endIcon,
              ],
            ),
        ],
      ),
    );
  }
}
