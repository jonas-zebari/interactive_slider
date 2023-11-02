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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            InteractiveSlider(
              startIcon: Icon(CupertinoIcons.volume_down),
              endIcon: Icon(CupertinoIcons.volume_up),
            ),
            InteractiveSlider(
              iconPosition: IconPosition.below,
              startIcon: Icon(CupertinoIcons.volume_down),
              endIcon: Icon(CupertinoIcons.volume_up),
              centerIcon: Text('Center'),
            ),
            InteractiveSlider(
              iconPosition: IconPosition.inside,
              startIcon: Icon(CupertinoIcons.volume_down),
              endIcon: Icon(CupertinoIcons.volume_up),
              centerIcon: Text('Center'),
              unfocusedHeight: 40,
              focusedHeight: 50,
              iconGap: 16,
            ),
            Divider(),
            InteractiveSlider(
              unfocusedHeight: 30,
              focusedHeight: 40,
            ),
            InteractiveSlider(
              unfocusedHeight: 30,
              focusedHeight: 40,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            InteractiveSlider(
              unfocusedHeight: 30,
              focusedHeight: 40,
              shapeBorder: BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            Divider(),
            InteractiveSlider(
              unfocusedOpacity: 1,
              unfocusedHeight: 30,
              focusedHeight: 40,
              foregroundColor: Colors.deepPurple,
            ),
            InteractiveSlider(
              unfocusedOpacity: 1,
              unfocusedHeight: 30,
              focusedHeight: 40,
              gradient: LinearGradient(colors: [Colors.green, Colors.red]),
            ),
            InteractiveSlider(
              unfocusedOpacity: 1,
              unfocusedHeight: 30,
              focusedHeight: 40,
              gradient: LinearGradient(colors: [Colors.green, Colors.red]),
              gradientSize: GradientSize.progressWidth,
            ),
          ],
        ),
      ),
    );
  }
}
