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
  double _amplitude = 0.0;
  double _amplitudeThreshold = 0.05; // Initial value for the amplitude threshold
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
      await JeefoPitchDetector.activate();
    }
    setState(() {
      _isMicrophoneActive = !_isMicrophoneActive;
    });
  }

  Future<void> _updateJPD() async {
    List<double> values = await JeefoPitchDetector.getValues(_amplitudeThreshold);
    double pitch = values[0];
    double amplitude = values[1];
    if (pitch > 0) {
      setState(() {
        _pitch = pitch;
        _note = JeefoPitchDetector.pitchToNoteName(pitch);
        _amplitude = amplitude;
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
              'Amplitude: ${_amplitude.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Amplitude threshold: ${_amplitudeThreshold.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Text(
              'FPS: $_fps',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Slider(
              value: _amplitudeThreshold,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: 'Amplitude Threshold: ${_amplitudeThreshold.toStringAsFixed(2)}',
              onChanged: (value) {
                setState(() {
                  _amplitudeThreshold = value;
                });
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