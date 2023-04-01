import 'package:flutter_test/flutter_test.dart';
import 'package:jeefo_pitch_detector/jeefo_pitch_detector_platform_interface.dart';
import 'package:jeefo_pitch_detector/jeefo_pitch_detector_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockJeefoPitchDetectorPlatform
    with MockPlatformInterfaceMixin
    implements JeefoPitchDetectorPlatform {

  @override
  Future<void> activate() async {}

  @override
  Future<double> getPitch() async => 0;
}

void main() {
  final JeefoPitchDetectorPlatform initialPlatform = JeefoPitchDetectorPlatform.instance;

  test('$JeefoPitchDetectorChannel is the default instance', () {
    expect(initialPlatform, isInstanceOf<JeefoPitchDetectorChannel>());
  });

  test('getPlatformVersion', () async {
  });
}
