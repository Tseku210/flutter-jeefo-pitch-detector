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

- (void)activateWithCompletion:(void (^)(BOOL result))completion;
- (void)start;

@end

NS_ASSUME_NONNULL_END
