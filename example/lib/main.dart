import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Interactive Slider'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = InteractiveSliderController(0.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _controller.value = 0.0,
                  child: const Text('Min'),
                ),
                ValueListenableBuilder<double>(
                  valueListenable: _controller,
                  builder: (context, progress, child) =>
                      Text(progress.toStringAsFixed(3)),
                ),
                ElevatedButton(
                  onPressed: () => _controller.value = 1.0,
                  child: const Text('Max'),
                ),
              ],
            ),
          ),
          InteractiveSlider(
            controller: _controller,
            startIcon: const Icon(CupertinoIcons.minus_circle),
            endIcon: const Icon(CupertinoIcons.add_circled),
            onChanged: (value) {
              // This callback runs repeatedly for every update
            },
            onProgressUpdated: (value) {
              // This callback runs once when the user finishes updating the slider
            },
          ),
          const Divider(),
          const InteractiveSlider(
            enabled: true,
            startIcon: Icon(CupertinoIcons.volume_down),
            endIcon: Icon(CupertinoIcons.volume_up),
          ),
          const InteractiveSlider(
            iconPosition: IconPosition.below,
            startIcon: Icon(CupertinoIcons.volume_down),
            endIcon: Icon(CupertinoIcons.volume_up),
            centerIcon: Text('Center'),
          ),
          const InteractiveSlider(
            iconPosition: IconPosition.inside,
            startIcon: Icon(CupertinoIcons.volume_down),
            endIcon: Icon(CupertinoIcons.volume_up),
            centerIcon: Text('Center'),
            unfocusedHeight: 40,
            focusedHeight: 50,
            iconGap: 16,
          ),
          const Divider(),
          const InteractiveSlider(
            unfocusedHeight: 30,
            focusedHeight: 40,
          ),
          const InteractiveSlider(
            unfocusedHeight: 30,
            focusedHeight: 40,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          const InteractiveSlider(
            unfocusedHeight: 30,
            focusedHeight: 40,
            shapeBorder: BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          const Divider(),
          const InteractiveSlider(
            unfocusedOpacity: 1,
            unfocusedHeight: 30,
            focusedHeight: 40,
            foregroundColor: Colors.deepPurple,
          ),
          const InteractiveSlider(
            unfocusedOpacity: 1,
            unfocusedHeight: 30,
            focusedHeight: 40,
            gradient: LinearGradient(colors: [Colors.green, Colors.red]),
          ),
          const InteractiveSlider(
            unfocusedOpacity: 1,
            unfocusedHeight: 30,
            focusedHeight: 40,
            gradient: LinearGradient(colors: [Colors.green, Colors.red]),
            gradientSize: GradientSize.progressWidth,
          ),
        ],
      ),
    );
  }
}
