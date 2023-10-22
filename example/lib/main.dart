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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final _controller = InteractiveSliderController(0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _controller,
              builder: (context, progress, _) {
                return Text(
                  'Normal: ${progress.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineLarge,
                );
              },
            ),
            ElevatedButton(
              onPressed: () => _controller.value = 0.0,
              child: const Text('Reset'),
            ),
            InteractiveSlider(
              controller: _controller,
              startIcon: const Icon(CupertinoIcons.volume_down),
              endIcon: const Icon(CupertinoIcons.volume_up),
              min: 1.0,
              max: 15.0,
              focusedHeight: 35,
              unfocusedHeight: 25,
              shapeBorder: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            const InteractiveSlider(
              startIcon: Icon(CupertinoIcons.minus),
              centerIcon: Text('Center'),
              endIcon: Icon(CupertinoIcons.plus),
              iconPosition: IconPosition.below,
            ),
            const InteractiveSlider(
              padding: EdgeInsets.symmetric(horizontal: 16),
              startIcon: Icon(CupertinoIcons.minus),
              centerIcon: Text('Center'),
              endIcon: Icon(CupertinoIcons.plus),
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              iconPosition: IconPosition.inside,
              focusedHeight: 45,
              unfocusedHeight: 35,
            ),
            const InteractiveSlider(
              startIcon: Icon(CupertinoIcons.minus),
              endIcon: Icon(CupertinoIcons.plus),
              iconPosition: IconPosition.inside,
              unfocusedOpacity: 1.0,
              unfocusedHeight: 30,
              focusedHeight: 40,
              foregroundColor: Colors.white,
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
