import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'jeefo_pitch_detector_platform_interface.dart';

/// An implementation of [JeefoPitchDetectorPlatform] that uses method channels.
class JeefoPitchDetectorChannel extends JeefoPitchDetectorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final channel = const MethodChannel('jeefo.pitch_detector');

  @override
  Future<void> activate() async {
    await channel.invokeMethod<void>('activate');
  }

  @override
  Future<double> getPitch() async {
    return await channel.invokeMethod<double>('get_pitch') ?? 0;
  }
}
