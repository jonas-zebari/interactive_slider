library interactive_slider;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider_controller.dart';
import 'package:interactive_slider/interactive_slider_painter.dart';

export 'package:interactive_slider/interactive_slider_controller.dart';

enum IconPosition {
  below,
  inline,
  inside,
}

class InteractiveSlider extends StatefulWidget {
  static const defaultTransitionPeriod = 0.8;
  static const easeTransitionPeriod = 2.0;

  const InteractiveSlider({
    super.key,
    this.padding = const EdgeInsets.all(16),
    EdgeInsets? unfocusedMargin,
    this.focusedMargin = EdgeInsets.zero,
    this.startIcon,
    this.centerIcon,
    this.endIcon,
    this.transitionDuration = const Duration(milliseconds: 750),
    this.transitionCurvePeriod = InteractiveSlider.defaultTransitionPeriod,
    this.backgroundColor,
    this.foregroundColor,
    this.shapeBorder = const StadiumBorder(),
    this.unfocusedSize = 10.0,
    this.focusedSize = 20.0,
    double? unfocusedOpacity,
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
    this.direction = Axis.horizontal,
    this.mainAxisSize,
  })  : unfocusedOpacity = unfocusedOpacity ??
            (iconPosition == IconPosition.inside ? 1.0 : 0.4),
        unfocusedMargin = direction == Axis.horizontal
            ? const EdgeInsets.symmetric(horizontal: 16)
            : const EdgeInsets.symmetric(vertical: 16),
        assert(transitionCurvePeriod > 0.0),
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
  final double unfocusedSize;

  /// Slider height when the user is interacting with the slider
  final double focusedSize;

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

  /// The main axis of the slider
  final Axis direction;

  /// The maximum cross axis size to enforce
  final double? mainAxisSize;

  @override
  State<InteractiveSlider> createState() => _InteractiveSliderState();
}

class _InteractiveSliderState extends State<InteractiveSlider> {
  late final _size = ValueNotifier(widget.unfocusedSize);
  late final _margin = ValueNotifier(widget.unfocusedMargin);
  late final _opacity = ValueNotifier(widget.unfocusedOpacity);
  late final _progress =
      widget.controller ?? ValueNotifier(widget.initialProgress);
  final _startIconKey = GlobalKey();
  final _endIconKey = GlobalKey();
  late ElasticOutCurve _transitionCurve;
  late double _maxSizeFactor;
  var _isFocused = false;

  List<Widget> get _iconChildren {
    return [
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
    ];
  }

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
    if (_isFocused) {
      _size.value = widget.focusedSize;
      _margin.value = widget.focusedMargin;
      _opacity.value = 1.0;
    } else {
      _size.value = widget.unfocusedSize;
      _margin.value = widget.unfocusedMargin;
      _opacity.value = widget.unfocusedOpacity;
    }
  }

  @override
  void dispose() {
    _size.dispose();
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
    final innerChildColor = widget.iconPosition == IconPosition.inside
        ? Colors.grey.shade500
        : brightnessColor;
    final textStyle =
        widget.style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final horizontalPadding = EdgeInsets.only(
      left: widget.startIcon != null ? widget.iconGap : 0,
      right: widget.endIcon != null ? widget.iconGap : 0,
    );
    final verticalPadding = EdgeInsets.only(
      bottom: widget.startIcon != null ? widget.iconGap : 0,
      top: widget.endIcon != null ? widget.iconGap : 0,
    );
    Widget slider = ValueListenableBuilder<double>(
      valueListenable: _size,
      builder: (context, height, child) {
        return AnimatedContainer(
          clipBehavior: Clip.antiAlias,
          width: switch (widget.direction) {
            Axis.horizontal => widget.mainAxisSize ?? double.infinity,
            Axis.vertical => _size.value,
          },
          height: switch (widget.direction) {
            Axis.horizontal => _size.value,
            Axis.vertical => widget.mainAxisSize ?? double.infinity,
          },
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
            direction: widget.direction,
            progress: _progress,
            color: widget.foregroundColor ?? brightnessColor,
          ),
          child: switch (widget.iconPosition) {
            IconPosition.inside => Padding(
                padding: widget.direction == Axis.horizontal
                    ? horizontalPadding
                    : verticalPadding,
                child: Flex(
                  direction: widget.direction,
                  children: _iconChildren,
                ),
              ),
            IconPosition.inline when widget.centerIcon != null =>
              Center(child: widget.centerIcon),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
    if (widget.startIcon != null ||
        widget.centerIcon != null ||
        widget.endIcon != null) {
      slider = Column(
        children: [
          switch (widget.iconPosition) {
            IconPosition.below => Padding(
                padding: EdgeInsets.only(bottom: widget.iconGap),
                child: slider,
              ),
            IconPosition.inside => slider,
            IconPosition.inline => Row(
                children: [
                  if (widget.startIcon case var startIcon?)
                    ValueListenableBuilder<double>(
                      key: _startIconKey,
                      valueListenable: _opacity,
                      builder: _opacityBuilder,
                      child: startIcon,
                    ),
                  Expanded(
                    child: Padding(
                      padding: widget.direction == Axis.horizontal
                          ? horizontalPadding
                          : verticalPadding,
                      child: slider,
                    ),
                  ),
                  if (widget.endIcon case var endIcon?)
                    ValueListenableBuilder<double>(
                      key: _endIconKey,
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
              children: _iconChildren,
            ),
        ],
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart:
          widget.direction == Axis.horizontal ? _onDragStart : null,
      onHorizontalDragEnd:
          widget.direction == Axis.horizontal ? _onDragEnd : null,
      onHorizontalDragUpdate:
          widget.direction == Axis.horizontal ? _onDragUpdate : null,
      onVerticalDragStart:
          widget.direction == Axis.vertical ? _onDragStart : null,
      onVerticalDragEnd: widget.direction == Axis.vertical ? _onDragEnd : null,
      onVerticalDragUpdate:
          widget.direction == Axis.vertical ? _onDragUpdate : null,
      child: IconTheme(
        data: theme.iconTheme.copyWith(
          color: widget.iconColor ?? widget.foregroundColor ?? innerChildColor,
          size: widget.iconSize,
        ),
        child: DefaultTextStyle(
          style: textStyle.copyWith(
            color: widget.foregroundColor ?? innerChildColor,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Visibility.maintain(
                visible: false,
                child: _Prototype(
                  padding: widget.padding,
                  height: widget.focusedSize * _maxSizeFactor,
                  iconGap: widget.iconGap,
                  startIcon: widget.startIcon ?? const SizedBox.shrink(),
                  centerIcon: widget.centerIcon ?? const SizedBox.shrink(),
                  endIcon: widget.endIcon ?? const SizedBox.shrink(),
                  iconPosition: widget.iconPosition,
                ),
              ),
              Padding(
                padding: widget.padding,
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
            ],
          ),
        ),
      ),
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

  void _onDragStart(DragStartDetails details) {
    if (!mounted) return;
    _isFocused = true;
    _size.value = widget.focusedSize;
    _opacity.value = 1.0;
    _margin.value = widget.focusedMargin;
  }

  void _onDragEnd(DragEndDetails details) {
    if (!mounted) return;
    _isFocused = false;
    _size.value = widget.unfocusedSize;
    _opacity.value = widget.unfocusedOpacity;
    _margin.value = widget.unfocusedMargin;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!mounted) return;
    final isHorizontal = widget.direction == Axis.horizontal;
    final renderBox = context.findRenderObject() as RenderBox;
    var sliderSize = isHorizontal
        ? renderBox.size.width - widget.padding.horizontal
        : renderBox.size.height - widget.padding.vertical;
    if (widget.iconPosition == IconPosition.inline) {
      final startIconRenderBox =
          _startIconKey.currentContext?.findRenderObject() as RenderBox?;
      final endIconRenderBox =
          _endIconKey.currentContext?.findRenderObject() as RenderBox?;
      final startIconSize = isHorizontal
          ? startIconRenderBox?.size.width
          : startIconRenderBox?.size.height;
      final endIconSize = isHorizontal
          ? endIconRenderBox?.size.width
          : endIconRenderBox?.size.height;
      if (startIconSize != null) {
        sliderSize -= startIconSize;
      }
      if (endIconSize != null) {
        sliderSize -= endIconSize;
      }
      sliderSize -= widget.iconGap *
          (widget.startIcon != null && widget.endIcon != null ? 2 : 1);
    }
    final primaryDelta = isHorizontal ? details.delta.dx : -details.delta.dy;
    _progress.value =
        (_progress.value + (primaryDelta / sliderSize)).clamp(0.0, 1.0);
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
