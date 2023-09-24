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
  var _value = 1.0;

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
            Text(
              'Transformed: ${_value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            ElevatedButton(
              onPressed: () => _controller.value = 0.0,
              child: const Text('Reset'),
            ),
            InteractiveSlider(
              controller: _controller,
              margin: const EdgeInsets.all(16),
              startIcon: const Icon(CupertinoIcons.volume_down),
              centerIcon: const Text('Center'),
              endIcon: const Icon(CupertinoIcons.volume_up),
              foregroundColor: Colors.white,
              iconColor: Colors.white,
              min: 1.0,
              max: 15.0,
              onChanged: (value) => setState(() => _value = value),
            ),
          ],
        ),
      ),
    );
  }
}
