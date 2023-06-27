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
@property (nonatomic, assign) BOOL is_activated;

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
  self.is_activated = YES;
  completion(result);
}

- (void)deactivateWithCompletion:(void (^)(BOOL result))completion {
  [self.audio_engine stop];
  AVAudioInputNode *inputNode = self.audio_engine.inputNode;
  [inputNode removeTapOnBus:0];
  self.is_activated = NO;
  
  jpd_destroy();
  completion(YES);
}

- (void)start {
  AVAudioInputNode *inputNode = self.audio_engine.inputNode;
  AVAudioFormat *inputFormat = [inputNode inputFormatForBus:0];

  AVAudioFrameCount bufferSize = 1024;

  [inputNode installTapOnBus:0 bufferSize:bufferSize format:inputFormat block:^(AVAudioPCMBuffer *buffer, AVAudioTime *time) {
    if (self.is_activated) {
      [self getValues:buffer];
    }
  }];

  [self.audio_engine startAndReturnError:nil];

  jpd_init(bufferSize, 20);
  jpd_set_sample_rate((int32_t)inputFormat.sampleRate);
}

- (void)getValues:(AVAudioPCMBuffer *)buffer {
  int length = buffer.frameLength;

  float values[3];
  values[0] = (float)self.pitch;
  values[1] = (float)self.amplitude;
  values[2] = (float)self.amplitudeThreshold;

  float *floatData = buffer.floatChannelData[0];
  jpd_get_values(floatData, length, values);

  self.pitch = values[0];
  self.amplitude = values[1];
}

- (instancetype)init {
  _audio_engine = [[AVAudioEngine alloc] init];
  _is_activated = false;
  return [super init];
}

- (void)dealloc {
  jpd_destroy();
}

@end
