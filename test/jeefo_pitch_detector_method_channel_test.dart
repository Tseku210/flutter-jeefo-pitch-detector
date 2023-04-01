import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeefo_pitch_detector/jeefo_pitch_detector_method_channel.dart';

void main() {
  JeefoPitchDetectorChannel platform = JeefoPitchDetectorChannel();
  const MethodChannel channel = MethodChannel('jeefo.pitch_detector');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
