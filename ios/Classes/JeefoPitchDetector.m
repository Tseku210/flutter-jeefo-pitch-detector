//
//  JeefoPitchDetector.m
//  objc
//
//  Created by Batkhishig on 2023.04.01.
//

#import "JeefoPitchDetector.h"
#import "FFTPitchAnalyser/include/FFTPitchAnalyser.h"

@interface JeefoPitchDetector ()

@property (nonatomic, strong) AVAudioEngine *audio_engine;
@property (nonatomic, assign) zt_data *data;
@property (nonatomic, assign) zt_ptrack *ptrack;

@end

@implementation JeefoPitchDetector

+ (instancetype)shared {
  static JeefoPitchDetector *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[JeefoPitchDetector alloc] init];
  });
  return instance;
}

- (void)activateWithCompletion:(void (^)(BOOL result))completion {
  __block BOOL result = NO;
  switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio]) {
    case AVAuthorizationStatusAuthorized:
      [self start];
      result = YES;
      break;
    case AVAuthorizationStatusNotDetermined: {
      dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
      [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (granted) {
          [self start];
          result = YES;
        }
        dispatch_semaphore_signal(semaphore);
      }];
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
      break;
    }
    default:
      result = NO;
      break;
  }
  completion(result);
}

- (void)start {
  AVAudioInputNode *inputNode = self.audio_engine.inputNode;
  AVAudioFormat *inputFormat = [inputNode inputFormatForBus:0];
  
  AVAudioFrameCount bufferSize = 1024;
  //  AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:inputFormat frameCapacity:bufferSize];
  
  [inputNode installTapOnBus:0 bufferSize:bufferSize format:inputFormat block:^(AVAudioPCMBuffer *buffer, AVAudioTime *time) {
    self.pitch = [self getPitch:buffer amplitudeThreshold:0];
  }];
  
  [self.audio_engine startAndReturnError:nil];
  
  zt_create(&_data);
  _data->sr = (int32_t)inputFormat.sampleRate;
  zt_ptrack_create(&_ptrack);
  zt_ptrack_init(_data, _ptrack, bufferSize, 20);
}

- (double)getPitch:(AVAudioPCMBuffer *)buffer amplitudeThreshold:(double)amplitudeThreshold {
  float *floatData = buffer.floatChannelData[0];
  
  float fpitch = 0;
  float famplitude = 0;
  
  for (int i = 0; i < buffer.frameLength; i++) {
    zt_ptrack_compute(_data, _ptrack, &floatData[i], &fpitch, &famplitude);
  }
  
  double pitch = fpitch;
  double amplitude = famplitude;
  
  return (amplitude > amplitudeThreshold && pitch > 0) ? pitch : 0;
}

- (instancetype)init {
  _audio_engine = [[AVAudioEngine alloc] init];
  _data   = NULL;
  _ptrack = NULL;
  return [super init];
}

- (void)dealloc {
  if (_ptrack != NULL) zt_ptrack_destroy(&_ptrack);
  if (_data != NULL) zt_destroy(&_data);
}

@end
