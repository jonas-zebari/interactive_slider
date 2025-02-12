## v0.5.1
* Updates dependencies
* Fixes info lint

## v0.5.0
* Adds onFocused callback that fires when the user starts an interaction (elliothux)
* Fixes a bug where externally supplied controllers were being disposed of too soon (valentingrigorean)

## v0.4.0

* Adds segmentation controls
  * Easily control the number of discrete segments
  * The color of segment dividers
  * The thickness of segment dividers
* Fixes a bug where the slider would not enlarge until horizontal movement was detected, which was inconsistent with Apple's sliders

## v0.3.0

* Adds [enabled] flag to block user input
* Adds [disabledOpacity] to customize disabled state

## v0.2.2

* Adds additional example case to show a controller being used

## v0.2.1

* Fixes documentation

## v0.2.0

* Adds gradient progress bar option
* Adds icon builders tied to slider progress

## v0.1.1

* Adds the option to place icons inside the slider bar
* Fixes the inline icon position slider update calculation

## v0.1.0

* [BREAKING] Fixes issue where the slider's size transition would move other UI elements
  * Use scale options instead of transition old transition margin
* Adds icon position options
* Adds icon size field

## v0.0.2

* Addresses pub.dev package analysis scores

## v0.0.1

* Initial release of interactive_slider
