<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

A continuous slider widget inspired by the volume slider in the Apple Music app. This widget can
be used with little to no setup but is still fully customizable!

<img height="250" src="https://github.com/jonas-zebari/interactive_slider/blob/main/pub/icons.gif?raw=true" alt="Animated gif of slider being used">
<img height="250" src="https://github.com/jonas-zebari/interactive_slider/blob/main/pub/shapes.gif?raw=true" alt="Animated gif of slider being used">
<img height="250" src="https://github.com/jonas-zebari/interactive_slider/blob/main/pub/colors.gif?raw=true" alt="Animated gif of slider being used">

## Features

Use the stock slider or customize:
* Built in padding for convenience
* Adjustable size transition
* Use any widget for a start/end icon and center label
* Use any transition duration and curve
* Provide any shape border for the progress bar
* Use the normalized progress value or easily provide a min/max to be automatically transformed
* Animate start and end icons using slider progress
* Color the slider's porgress with a gradient

## Getting started

Add to your dependencies:

```yaml
dependencies:
  interactive_slider: ^0.2.0
```

Then import:
```dart
import 'package:interactive_slider/interactive_slider.dart';
```

## Usage

```dart
InteractiveSlider(
  startIcon: const Icon(CupertinoIcons.volume_down),
  centerIcon: const Text('Center'),
  endIcon: const Icon(CupertinoIcons.volume_up),
  min: 1.0,
  max: 15.0,
  onChanged: (value) => setState(() => _value = value),
)
```

## Additional information

Please report any bugs and open any pull requests via GitHub.