import 'package:flutter/foundation.dart';

class InteractiveSliderController extends ValueNotifier<double> {
  InteractiveSliderController(super._value);

  @override
  set value(double value) => super.value = value.clamp(0.0, 1.0);
}
