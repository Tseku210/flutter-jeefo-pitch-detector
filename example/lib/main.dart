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
  String _note = 'Unknown';
  double _pitch = 0.0;
  double _confidence = 0.0;
  double _confidenceThreshold = 0.95;
  int _fps = 0;
  int _frameCount = 0;
  bool _isMicrophoneActive = false;
  DateTime _lastUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _toggleMicrophone();
    _updateJPD();
  }

  Future<void> _toggleMicrophone() async {
    if (_isMicrophoneActive) {
      await JeefoPitchDetector.deactivate();
    } else {
      await JeefoPitchDetector.activate(_confidenceThreshold);
    }
    setState(() {
      _isMicrophoneActive = !_isMicrophoneActive;
    });
  }

  Future<void> _updateJPD() async {
    List<double> values = await JeefoPitchDetector.getValues();
    double pitch = values[0];
    if (pitch > 0) {
      setState(() {
        _pitch = pitch;
        _note = JeefoPitchDetector.pitchToNoteName(pitch);
        _confidence = values[1];
      });
    }
    _frameCount++;
    if (DateTime.now().difference(_lastUpdateTime).inMilliseconds > 1000) {
      int fps =
      (_frameCount / (DateTime.now().difference(_lastUpdateTime).inMilliseconds / 1000)).floor();
      setState(() {
        _fps = fps;
      });
      _frameCount = 0;
      _lastUpdateTime = DateTime.now();
    }
    // Schedule the next update
    Future.delayed(const Duration(milliseconds: 14)).then((_) => _updateJPD());
  }

  Future<void> _updateThreshold(double threshold) async {
    await JeefoPitchDetector.setConfidenceThreshold(threshold);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isMicrophoneActive ? '${widget.title} (Active)' : widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Note: $_note',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Pitch: ${_pitch.toStringAsFixed(0)}Hz',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Confidence: ${_confidence.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Min confidence threshold: ${_confidenceThreshold.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Text(
              'FPS: $_fps',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Slider(
              value: _confidenceThreshold,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: 'Min confidence threshold: ${
                _confidenceThreshold.toStringAsFixed(2)
              }',
              onChanged: (value) {
                setState(() {
                  _confidenceThreshold = value;
                });
                _updateThreshold(value);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: _toggleMicrophone,
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(
              _isMicrophoneActive ? Colors.red : Colors.blue),
        ),
        child: Text(_isMicrophoneActive ? 'Deactivate Microphone' : 'Activate Microphone'),
      ),
    );
  }
}