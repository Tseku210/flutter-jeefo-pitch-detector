# jeefo_pitch_detector

IOS and Android cross platform native C microphone pitch detector using FFT 
analyse.

<img src="https://github.com/je3f0o/flutter-jeefo-pitch-detector/blob/master/screenshot.jpg" width="100" alt="Screenshot">

## Installation
```
dependencies:
  ...
  jeefo_pitch_detector:
    git:
      url: https://github.com/je3f0o/flutter-jeefo-pitch-detector.git
      ref: master
```

## Getting started
```dart
import 'package:jeefo_pitch_detector/jeefo_pitch_detector.dart';

// ...

class _MyHomePageState extends State<MyHomePage> {
  String _note  = "Unknown";
  double _pitch = 0.0;

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
    // do your thing...
  }
}
```

## API Docs

#### JeefoPitchDetector.activate()
It will request platform specific microphone usage if user hasn't already 
decided yet then activate Audio Engine and start recording samples to analyse.
```
await JeefoPitchDetector.activate();
```

#### JeefoPitchDetector.getPitch()
It will retrieve currently analysed FFT pitch from background thread.
```
double pitch = await JeefoPitchDetector.getPitch();
```

#### JeefoPitchDetector.getPitch()
It will retrieve currently analysed FFT pitch from background thread.
```
double pitch = await JeefoPitchDetector.getPitch();
```

#### JeefoPitchDetector.pitchToNoteName(double)
It will return a String representing closest musical note for given pitch.
```
String note = JeefoPitchDetector.pitchToNoteName(pitch);
```

## More configuration and API will be added next updates...

## License
*MIT*