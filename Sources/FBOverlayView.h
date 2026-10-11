#pragma once
#import <UIKit/UIKit.h>
#import "FBFrameMonitor.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBOverlayView : UIView
+ (instancetype)shared;
- (void)showOverlay;
- (void)hideOverlay;
- (void)updateWithStats:(FBFrameStats)stats;
- (void)applyPreferences;
@property (nonatomic, readonly) BOOL isVisible;
@end

NS_ASSUME_NONNULL_END
