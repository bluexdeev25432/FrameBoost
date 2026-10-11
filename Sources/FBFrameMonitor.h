#pragma once
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    double currentFPS;
    double currentFrametimeMS;
    double avgFPS;
    double minFPS;
    double maxFPS;
    double p95FrametimeMS;
    NSUInteger stutterCount;
    NSTimeInterval sessionDuration;
} FBFrameStats;

typedef void (^FBStatsBlock)(FBFrameStats stats);

@interface FBFrameMonitor : NSObject
+ (instancetype)shared;
@property (nonatomic, copy, nullable) FBStatsBlock onStatsUpdate;
@property (nonatomic, readonly) BOOL isMonitoring;
@property (nonatomic, readonly) FBFrameStats currentStats;
- (void)startMonitoring;
- (void)stopMonitoring;
- (void)resetSession;
@end

NS_ASSUME_NONNULL_END
