import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'jeefo_pitch_detector_method_channel.dart';

abstract class JeefoPitchDetectorPlatform extends PlatformInterface {
  /// Constructs a JeefoPitchDetectorPlatform.
  JeefoPitchDetectorPlatform() : super(token: _token);

  static final Object _token = Object();

  static JeefoPitchDetectorPlatform _instance = JeefoPitchDetectorChannel();

  /// The default instance of [JeefoPitchDetectorPlatform] to use.
  ///
  /// Defaults to [MethodChannelJeefoPitchDetector].
  static JeefoPitchDetectorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JeefoPitchDetectorPlatform] when
  /// they register themselves.
  static set instance(JeefoPitchDetectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> activate(double threshold) {
    throw UnimplementedError('activate(double threshold) has not been implemented.');
  }

  Future<List<double>> getValues() {
    throw UnimplementedError('getValues() has not been implemented.');
  }

  Future<void> setConfidenceThreshold(double threshold) {
    throw UnimplementedError('setConfidenceThreshold(double threshold) has not been implemented.');
  }

  Future<void> deactivate() {
    throw UnimplementedError('deactivate() has not been implemented.');
  }
}
