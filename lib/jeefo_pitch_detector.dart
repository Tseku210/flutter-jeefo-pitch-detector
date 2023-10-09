import 'dart:math';
import 'jeefo_pitch_detector_platform_interface.dart';

abstract class JeefoPitchDetector {
  static Future<void> activate(double threshold) async {
    await JeefoPitchDetectorPlatform.instance.activate(threshold);
  }

  static Future<void> deactivate() async {
    await JeefoPitchDetectorPlatform.instance.deactivate();
  }

  static Future<List<double>> getValues() async {
    return JeefoPitchDetectorPlatform.instance.getValues();
  }

  static Future<void> setConfidenceThreshold(double threshold) async {
    await JeefoPitchDetectorPlatform.instance.setConfidenceThreshold(threshold);
  }

  static String pitchToNoteName(double pitch) {
    int noteNum = (12 * (log(pitch / 440) / ln2)).round() + 69;
    if (noteNum < 0) return "Invalid note";
    int octave = noteNum ~/ 12 - 1;
    int noteIndex = noteNum % 12;
    List<String> noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
    return noteNames[noteIndex] + octave.toString();
  }
}
