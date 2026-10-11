// Frametime = interval between consecutive CADisplayLink callbacks.
// This reflects vsync delivery cadence, NOT GPU render latency.
// On ProMotion devices measured FPS varies with system refresh rate.

#import "FBFrameMonitor.h"
#import "FBStutterLog.h"
#import "FBPreferences.h"
#import <float.h>

@interface FBFrameMonitor ()
@property (nonatomic, assign) BOOL monitoring;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval lastTS;
@property (nonatomic, assign) NSTimeInterval lastSent;
@property (nonatomic, assign) NSTimeInterval sessionStart;
@property (nonatomic, assign) double sumFPS;
@property (nonatomic, assign) double minFPS;
@property (nonatomic, assign) double maxFPS;
@property (nonatomic, assign) NSUInteger frameCount;
@property (nonatomic, assign) double lastP95;
@property (nonatomic, assign) double cachedThreshMS;
@property (nonatomic, assign) double cachedInterval;
@property (nonatomic, assign) NSUInteger histHead;
@property (nonatomic, assign) NSUInteger histCount;
@property (nonatomic, strong) dispatch_queue_t sortQueue;
@property (nonatomic, assign) FBFrameStats currentStats;
@end

@implementation FBFrameMonitor {
    double _hist[256];
}

+ (instancetype)shared {
    static FBFrameMonitor *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FBFrameMonitor alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _sortQueue = dispatch_queue_create("com.bluexdeev25432.frameboost.sort", DISPATCH_QUEUE_SERIAL);
        _histHead = 0;
        _histCount = 0;
        _currentStats = (FBFrameStats){0};
        _lastP95 = 0.0;
        _cachedThreshMS = 33.3;
        _cachedInterval = 0.5;
        _sessionStart = CACurrentMediaTime();
        _lastTS = 0.0;
        _lastSent = 0.0;
        _sumFPS = 0.0;
        _frameCount = 0;
        _minFPS = DBL_MAX;
        _maxFPS = 0.0;
    }
    return self;
}

- (void)_refreshCachedPrefs {
    FBPreferences *prefs = [FBPreferences shared];
    _cachedThreshMS = prefs.stutterThresholdMS;
    _cachedInterval = prefs.updateInterval;
}

- (void)_resetInternal {
    memset(_hist, 0, sizeof(_hist));
    _histHead = 0;
    _histCount = 0;
    _sumFPS = 0.0;
    _frameCount = 0;
    _minFPS = DBL_MAX;
    _maxFPS = 0.0;
    _lastTS = 0.0;
    _lastSent = 0.0;
    _lastP95 = 0.0;
    _sessionStart = CACurrentMediaTime();
    [self _refreshCachedPrefs];
}

- (void)startMonitoring {
    if (self.monitoring) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self _resetInternal];
        self.monitoring = YES;
        if (self.displayLink) {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }

        CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(_handleDisplayLink:)];
        link.frameInterval = 1;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        if (floor(NSFoundationVersionNumber) >= 1854.0) {
            link.preferredFrameRateRange = CAFrameRateRangeMake(1, 120, 0);
        }
#pragma clang diagnostic pop
        [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = link;
    });
}

- (void)stopMonitoring {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.monitoring = NO;
        if (self.displayLink) {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
    });
}

- (void)resetSession {
    [self _resetInternal];
}

- (void)_handleDisplayLink:(CADisplayLink *)displayLink {
    if (!self.monitoring) {
        return;
    }

    NSTimeInterval now = displayLink.timestamp;
    if (_lastTS > 0.0) {
        NSTimeInterval delta = now - _lastTS;
        if (delta > 0.0 && delta <= 0.5) {
            double fps = 1.0 / delta;
            double ftMS = delta * 1000.0;

            size_t pos = _histHead;
            _hist[pos] = delta;
            _histHead = (_histHead + 1) % 256;
            if (_histCount < 256) {
                _histCount += 1;
            }

            _sumFPS += fps;
            _frameCount += 1;
            if (fps < _minFPS) {
                _minFPS = fps;
            }
            if (fps > _maxFPS) {
                _maxFPS = fps;
            }

            if (ftMS > _cachedThreshMS) {
                [[FBStutterLog shared] recordFrametimeMS:ftMS threshold:_cachedThreshMS];
            }

            NSTimeInterval elapsed = now - _lastSent;
            if (elapsed >= _cachedInterval) {
                [self _refreshCachedPrefs];
                FBFrameStats stats;
                stats.currentFPS = fps;
                stats.currentFrametimeMS = ftMS;
                stats.avgFPS = (_frameCount > 0) ? (_sumFPS / (double)_frameCount) : 0.0;
                stats.minFPS = (_frameCount > 0) ? _minFPS : 0.0;
                stats.maxFPS = (_frameCount > 0) ? _maxFPS : 0.0;
                stats.p95FrametimeMS = _lastP95;
                stats.stutterCount = [FBStutterLog shared].totalStutterCount;
                stats.sessionDuration = now - _sessionStart;
                _currentStats = stats;

                if (self.onStatsUpdate) {
                    self.onStatsUpdate(stats);
                }

                _lastSent = now;

                NSUInteger count = _histCount;
                if (count > 0) {
                    double *snapshot = malloc(sizeof(double) * count);
                    for (NSUInteger index = 0; index < count; index++) {
                        NSUInteger slot = (_histHead + 256 - count + index) % 256;
                        snapshot[index] = _hist[slot] * 1000.0;
                    }

                    dispatch_async(_sortQueue, ^{
                        double *sorted = malloc(sizeof(double) * count);
                        for (NSUInteger idx = 0; idx < count; idx++) {
                            sorted[idx] = snapshot[idx];
                        }
                        for (NSUInteger i = 1; i < count; i++) {
                            double value = sorted[i];
                            NSUInteger j = i;
                            while (j > 0 && sorted[j - 1] > value) {
                                sorted[j] = sorted[j - 1];
                                j -= 1;
                            }
                            sorted[j] = value;
                        }

                        if (count > 0) {
                            NSUInteger index = (NSUInteger)((0.95 * (double)(count - 1)));
                            if (index >= count) {
                                index = count - 1;
                            }
                            double p95 = sorted[index];
                            free(snapshot);
                            free(sorted);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.lastP95 = p95;
                                FBFrameStats updated = self.currentStats;
                                updated.p95FrametimeMS = p95;
                                self.currentStats = updated;
                            });
                        } else {
                            free(snapshot);
                            free(sorted);
                        }
                    });
                }
            }
        }
    }

    _lastTS = now;
}

@end
