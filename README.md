# jeefo_pitch_detector

IOS and Android cross platform native C microphone pitch detector using FFT 
analyse.

<div align="center">
  <img src="https://github.com/je3f0o/flutter-jeefo-pitch-detector/blob/master/screenshot.jpg" width="30%" alt="Screenshot">
</div>

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
### Android
On Android you should change `minSdkVersion` to `21` in 
`android/app/build.gradle` file.  Default `minSdkVersion` is `16` which has 
problem with linking Math library when building C codes. In the `fft.c` pitch 
analysing file using `log2` math function.  But flutter build system cannot 
linking math library against `fft.o` and it said `ld: undefined symbol log2` in 
my MacOS machine. So I changed `minSdkVersion` to `19` it does building. But I 
set `minSdkVersion` to `21` I don't know why... :)
```
android {
  ...
  defaultConfig {
    minSdkVersion 21
    ...
  }
  ...
}
```

### IOS
You need to add `Privacy - Microphone Usage Description` in `info.plist`.

### Example Code
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

### JeefoPitchDetector.getPitch() -> boolean
It will retrieve currently analysed FFT pitch from background thread.
```
double pitch = await JeefoPitchDetector.getPitch();
```

### JeefoPitchDetector.pitchToNoteName(double) -> String
It will return a String representing closest musical note for given pitch.
```
String note = JeefoPitchDetector.pitchToNoteName(pitch);
```

#### More configuration and API will be added next updates...

## License
**MIT**