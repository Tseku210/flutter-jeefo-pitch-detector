//
//  JeefoPitchDetector.h
//  objc
//
//  Created by Batkhishig on 2023.04.01.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JeefoPitchDetector : NSObject

@property (class, readonly) JeefoPitchDetector *shared;
@property (nonatomic, assign) double pitch;
@property (nonatomic, assign) double amplitude;
@property (nonatomic, assign) float  amplitudeThreshold;

- (void)activateWithCompletion:(void (^)(BOOL result))completion;
- (void)deactivateWithCompletion:(void (^)(BOOL result))completion;

@end

NS_ASSUME_NONNULL_END
