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

enum GradientSize {
  progressWidth,
  totalWidth,
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
    double? unfocusedOpacity,
    this.initialProgress = 0.0,
    this.onChanged,
    this.onProgressUpdated,
    this.onFocused,
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
    this.gradient,
    this.gradientSize = GradientSize.totalWidth,
    this.startIconBuilder,
    this.centerIconBuilder,
    this.endIconBuilder,
    this.enabled = true,
    this.disabledOpacity = 0.5,
    this.numberOfSegments,
    this.segmentDividerColor = Colors.grey,
    this.segmentDividerWidth = 1.0,
  })  : unfocusedOpacity = unfocusedOpacity ??
            (iconPosition == IconPosition.inside ? 1.0 : 0.4),
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

  /// A callback that runs when the user starts interacting with the slider
  final ValueChanged<double>? onFocused;

  /// A callback that runs when the user finishes updating the slider's progress
  final ValueChanged<double>? onProgressUpdated;

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

  /// Gradient to paint the progress bar with
  final Gradient? gradient;

  /// The width the gradient should be painted with - the size of the progress
  /// portion or the total length of the slider
  final GradientSize gradientSize;

  /// Widget builder to run when slider progress is updated
  final ValueWidgetBuilder<double>? startIconBuilder;

  /// Widget builder to run when slider progress is updated
  final ValueWidgetBuilder<double>? centerIconBuilder;

  /// Widget builder to run when slider progress is updated
  final ValueWidgetBuilder<double>? endIconBuilder;

  /// Sets whether the slider will register gesture events or not
  final bool enabled;

  /// Opacity of the slider and labels when [enabled] is false
  final double disabledOpacity;

  /// Turns the continuous slider into a segmented slider with the given
  /// [numberOfSegments]
  final int? numberOfSegments;

  /// The color of each vertical divider which separates each segment
  final Color segmentDividerColor;

  /// The thickness of each vertical divider which separates each segment
  final double segmentDividerWidth;

  @override
  State<InteractiveSlider> createState() => _InteractiveSliderState();
}

class _InteractiveSliderState extends State<InteractiveSlider> {
  late final _height = ValueNotifier(widget.unfocusedHeight);
  late final _opacity = ValueNotifier(widget.unfocusedOpacity);
  late final _margin = ValueNotifier(widget.unfocusedMargin);
  late final _progress =
      widget.controller ?? ValueNotifier(widget.initialProgress);
  final _startIconKey = GlobalKey();
  final _endIconKey = GlobalKey();
  late ElasticOutCurve _transitionCurve;
  late double _maxSizeFactor;

  List<Widget> get _iconChildren {
    return [
      if (widget.startIconBuilder case var startBuilder?)
        _iconBuilder(startBuilder, widget.startIcon)
      else if (widget.startIcon case var startIcon?)
        ValueListenableBuilder<double>(
          valueListenable: _opacity,
          builder: _opacityBuilder,
          child: startIcon,
        )
      else if (widget.endIcon case var endIcon?)
        Visibility.maintain(visible: false, child: endIcon),
      const Spacer(),
      if (widget.centerIconBuilder case var centerBuilder?)
        _iconBuilder(centerBuilder, widget.centerIcon)
      else if (widget.centerIcon case var centerIcon?)
        centerIcon,
      const Spacer(),
      if (widget.endIconBuilder case var endBuilder?)
        _iconBuilder(endBuilder, widget.endIcon)
      else if (widget.endIcon case var endIcon?)
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
    final innerChildColor = widget.iconPosition == IconPosition.inside
        ? Colors.grey.shade500
        : brightnessColor;
    final textStyle =
        widget.style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final horizontalPadding = EdgeInsets.only(
      left: widget.startIcon != null ? widget.iconGap : 0,
      right: widget.endIcon != null ? widget.iconGap : 0,
    );
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
            gradient: widget.gradient,
            gradientSize: widget.gradientSize,
            numberOfSegments: widget.numberOfSegments,
            segmentDividerColor: widget.segmentDividerColor,
            segmentDividerWidth: widget.segmentDividerWidth,
          ),
          child: switch (widget.iconPosition) {
            IconPosition.inside => Padding(
                padding: horizontalPadding,
                child: Row(children: _iconChildren),
              ),
            IconPosition.inline when widget.centerIconBuilder != null =>
              _iconBuilder(widget.centerIconBuilder!, widget.centerIcon),
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
                  if (widget.startIconBuilder case var startBuilder?)
                    _iconBuilder(startBuilder, widget.startIcon)
                  else if (widget.startIcon case var startIcon?)
                    ValueListenableBuilder<double>(
                      key: _startIconKey,
                      valueListenable: _opacity,
                      builder: _opacityBuilder,
                      child: startIcon,
                    ),
                  Expanded(
                    child: Padding(
                      padding: horizontalPadding,
                      child: slider,
                    ),
                  ),
                  if (widget.endIconBuilder case var endBuilder?)
                    _iconBuilder(endBuilder, widget.endIcon)
                  else if (widget.endIcon case var endIcon?)
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
    return AnimatedOpacity(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 300),
      opacity: widget.enabled ? 1.0 : widget.disabledOpacity,
      child: IgnorePointer(
        ignoring: !widget.enabled,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragDown: (_) => _dragStart(),
          onHorizontalDragStart: (_) => _dragStart(),
          onHorizontalDragEnd: (_) => _dragStop(),
          onHorizontalDragCancel: _dragStop,
          onHorizontalDragUpdate: (details) {
            if (!mounted) return;
            final renderBox = context.findRenderObject() as RenderBox;
            var sliderWidth = renderBox.size.width - widget.padding.horizontal;
            if (widget.iconPosition == IconPosition.inline) {
              final startIconRenderBox = _startIconKey.currentContext
                  ?.findRenderObject() as RenderBox?;
              final endIconRenderBox =
                  _endIconKey.currentContext?.findRenderObject() as RenderBox?;
              final startIconWidth = startIconRenderBox?.size.width;
              final endIconWidth = endIconRenderBox?.size.width;
              if (startIconWidth != null) {
                sliderWidth -= startIconWidth;
              }
              if (endIconWidth != null) {
                sliderWidth -= endIconWidth;
              }
              sliderWidth -= widget.iconGap * 2;
            }
            _progress.value =
                (_progress.value + (details.delta.dx / sliderWidth))
                    .clamp(0.0, 1.0);
          },
          child: IconTheme(
            data: theme.iconTheme.copyWith(
              color:
                  widget.iconColor ?? widget.foregroundColor ?? innerChildColor,
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
        ),
      ),
    );
  }

  void _dragStart() {
    if (!mounted) return;
    _height.value = widget.focusedHeight;
    _opacity.value = 1.0;
    _margin.value = widget.focusedMargin;
    widget.onFocused?.call(_progress.value);
  }

  void _dragStop() {
    if (!mounted) return;
    _height.value = widget.unfocusedHeight;
    _opacity.value = widget.unfocusedOpacity;
    _margin.value = widget.unfocusedMargin;
    if (widget.numberOfSegments case int numberOfSegments) {
      widget.onProgressUpdated
          ?.call(_adjustedSegmentedProgress(numberOfSegments));
    } else {
      widget.onProgressUpdated?.call(_adjustedProgress);
    }
  }

  Widget _opacityBuilder(BuildContext context, double opacity, Widget? child) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: widget.transitionDuration,
      curve: _transitionCurve,
      child: child,
    );
  }

  Widget _iconBuilder(ValueWidgetBuilder<double> builder, Widget? icon) {
    return ValueListenableBuilder<double>(
      valueListenable: _progress,
      builder: builder,
      child: icon,
    );
  }

  void _onChanged() {
    final progress = switch (widget.numberOfSegments) {
      int numberOfSegments => _adjustedSegmentedProgress(numberOfSegments),
      _ => _adjustedProgress,
    };
    widget.onChanged?.call(progress);
  }

  double get _adjustedProgress =>
      lerpDouble(widget.min, widget.max, _progress.value) ?? _progress.value;

  double _adjustedSegmentedProgress(int numberOfSegments) {
    final segment = (_progress.value * numberOfSegments).round();
    final step = (widget.max - widget.min) / numberOfSegments;
    return (segment * step) + widget.min;
  }

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
