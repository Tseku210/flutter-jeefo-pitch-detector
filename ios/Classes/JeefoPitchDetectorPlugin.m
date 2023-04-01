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
  } else if ([@"get_pitch" isEqualToString:call.method]) {
    result(@(JeefoPitchDetector.shared.pitch));
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end