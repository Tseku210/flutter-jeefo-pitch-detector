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
  Future<List<double>> getValues(double amplitudeThreshold) async {
    final dynamic result = await channel.invokeMethod('get_values', {
      'amplitudeThreshold': amplitudeThreshold,
    });

    if (result is List<dynamic>) {
      return result.cast<double>();
    } else {
      throw Exception('Invalid result type');
    }
  }

  @override
  Future<void> deactivate() async {
    await channel.invokeMethod<void>('deactivate');
  }
}
