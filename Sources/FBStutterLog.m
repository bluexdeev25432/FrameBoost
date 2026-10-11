#import "FBStutterLog.h"
#import <os/lock.h>
#import <QuartzCore/QuartzCore.h>

typedef struct {
    double timestamp;
    double frametimeMS;
    double thresholdMS;
} FBStutterEvent;

@implementation FBStutterLog {
    FBStutterEvent _events[512];
    os_unfair_lock _lock;
    NSUInteger _head;
    NSUInteger _count;
    NSUInteger _totalCount;
}

+ (instancetype)shared {
    static FBStutterLog *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FBStutterLog alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = OS_UNFAIR_LOCK_INIT;
        _head = 0;
        _count = 0;
        _totalCount = 0;
    }
    return self;
}

- (void)recordFrametimeMS:(double)ms threshold:(double)threshold {
    FBStutterEvent event = {
        .timestamp = CACurrentMediaTime(),
        .frametimeMS = ms,
        .thresholdMS = threshold
    };

    os_unfair_lock_lock(&_lock);
    _events[_head] = event;
    _head = (_head + 1) % 512;
    if (_count < 512) {
        _count += 1;
    }
    _totalCount += 1;
    os_unfair_lock_unlock(&_lock);
}

- (void)clearLog {
    os_unfair_lock_lock(&_lock);
    _head = 0;
    _count = 0;
    _totalCount = 0;
    os_unfair_lock_unlock(&_lock);
}

- (NSString *)exportReport {
    FBStutterEvent events[512];
    NSUInteger count = 0;
    NSUInteger head = 0;

    os_unfair_lock_lock(&_lock);
    count = _count;
    head = _head;
    memcpy(events, _events, sizeof(FBStutterEvent) * 512);
    os_unfair_lock_unlock(&_lock);

    NSMutableString *report = [NSMutableString stringWithFormat:@"FrameBoost stutter log (v%s) - %@\n", FBVERSION, [NSDate date]];

    for (NSUInteger index = 0; index < count; index++) {
        NSUInteger slot = (head + 512 - count + index) % 512;
        FBStutterEvent event = events[slot];
        [report appendFormat:@"+%.3fs  %.2f ms (thr %.2f ms)\n", event.timestamp, event.frametimeMS, event.thresholdMS];
    }

    if (count == 0) {
        [report appendString:@"No stutters recorded.\n"];
    }

    return report;
}

- (void)writeReportToDocuments {
    NSString *report = [self exportReport];
    NSString *path = @"/var/mobile/Documents/frameboost_stutter.log";
    NSError *error = nil;
    @try {
        [report writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    } @catch (NSException *exception) {
        (void)exception;
    }
}

- (NSUInteger)totalStutterCount {
    NSUInteger count = 0;
    os_unfair_lock_lock(&_lock);
    count = _totalCount;
    os_unfair_lock_unlock(&_lock);
    return count;
}

@end
