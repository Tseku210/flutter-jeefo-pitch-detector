import 'package:flutter/material.dart';
import 'package:jeefo_pitch_detector/jeefo_pitch_detector.dart';

void main() {
  runApp(const MaterialApp(
    home: MyHomePage(title: 'Home'),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _note = "Unknown";
  double _pitch = 0.0;
  int _fps = 0;
  int _frameCount = 0;
  DateTime _lastUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _activateMicrophone().then((_) {
      _updatePitch();
    });
  }

  Future<void> _activateMicrophone() async {
    await JeefoPitchDetector.activate();
  }

  Future<void> _updatePitch() async {
    double pitch = await JeefoPitchDetector.getPitch();
    if (pitch > 0) {
      setState(() {
        _pitch = pitch;
        _note = JeefoPitchDetector.pitchToNoteName(pitch);
      });
    }
    _frameCount++;
    if (DateTime.now().difference(_lastUpdateTime).inMilliseconds > 1000) {
      int fps = (_frameCount / (DateTime.now().difference(_lastUpdateTime).inMilliseconds / 1000)).floor();
      setState(() {
        _fps = fps;
      });
      _frameCount = 0;
      _lastUpdateTime = DateTime.now();
    }
    // Schedule the next update
    Future.delayed(const Duration(milliseconds: 14)).then((_) => _updatePitch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Note: $_note',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Pitch: ${_pitch.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              'FPS: $_fps',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}