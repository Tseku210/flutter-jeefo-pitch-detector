#import "JeefoPitchDetectorPlugin.h"
#import "JeefoPitchDetector.h"

@implementation JeefoPitchDetectorPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"jeefo.pitch_detector"
            binaryMessenger:[registrar messenger]];
  JeefoPitchDetectorPlugin* instance = [[JeefoPitchDetectorPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"activate" isEqualToString:call.method]) {
    [JeefoPitchDetector.shared activateWithCompletion:^(BOOL success) {
      result(@(success));
    }];
  } else if ([@"get_values" isEqualToString:call.method]) {
    NSNumber *threshold = call.arguments[@"amplitudeThreshold"];
    if (threshold != nil) {
      JeefoPitchDetector.shared.amplitudeThreshold = threshold.floatValue;
    }
    
    double pitch     = JeefoPitchDetector.shared.pitch;
    double amplitude = JeefoPitchDetector.shared.amplitude;
    NSArray *values = @[ @(pitch), @(amplitude) ];
    
    result(values);
  } else if ([@"deactivate" isEqualToString:call.method]) {
    [JeefoPitchDetector.shared deactivateWithCompletion:^(BOOL success) {
      result(@(success));
    }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
