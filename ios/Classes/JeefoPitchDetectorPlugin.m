#import "JeefoPitchDetectorPlugin.h"
#import "JeefoPitchDetector.h"
#import "FFTPitchAnalyser/include/jeefo_pitch_detector.h"

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
    NSNumber *threshold = call.arguments[@"threshold"];
    assert(threshold != NULL);
    [JeefoPitchDetector.shared activateWithThreshold:threshold.floatValue completion:^(BOOL success) {
      result(@(success));
    }];
  } else if ([@"set_confidence_threshold" isEqualToString:call.method]) {
    NSNumber *threshold = call.arguments[@"threshold"];
    assert(threshold != NULL);
    jpd_set_confidence_threshold(threshold.floatValue);
    result(nil);
  } else if ([@"get_values" isEqualToString:call.method]) {
    double pitch      = JeefoPitchDetector.shared.pitch;
    double confidence = JeefoPitchDetector.shared.confidence;
    NSArray *values = @[
      @(pitch),
      @(confidence)
    ];
    
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
