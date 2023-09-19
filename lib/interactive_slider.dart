library interactive_slider;

import 'package:flutter/material.dart';

class InteractiveSlider extends StatefulWidget {
  const InteractiveSlider({super.key});

  @override
  State<InteractiveSlider> createState() => _InteractiveSliderState();
}

class _InteractiveSliderState extends State<InteractiveSlider> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
