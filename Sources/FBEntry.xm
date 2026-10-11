#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <notify.h>
#import "FBPreferences.h"
#import "FBFrameMonitor.h"
#import "FBOverlayView.h"
#import "FBStutterLog.h"

static int s_token = NOTIFY_TOKEN_INVALID;
static BOOL s_active = NO;

static NSString *FBBundleID(void) {
    return [[NSBundle mainBundle] bundleIdentifier] ?: @"";
}

static BOOL FBShouldActivate(void) {
    FBPreferences *prefs = [FBPreferences shared];
    if (!prefs.tweakEnabled) {
        return NO;
    }
    if (prefs.allowedBundleIDs.count == 0) {
        return YES;
    }
    return [prefs.allowedBundleIDs containsObject:FBBundleID()];
}

static void FBStart(void) {
    if (s_active) {
        return;
    }
    s_active = YES;
    [[FBFrameMonitor shared] startMonitoring];
    [FBFrameMonitor shared].onStatsUpdate = ^(FBFrameStats stats) {
        [FBOverlayView.shared updateWithStats:stats];
    };
    if ([FBPreferences shared].overlayEnabled) {
        [FBOverlayView.shared showOverlay];
        [FBOverlayView.shared applyPreferences];
    }
}

static void FBStop(void) {
    if (!s_active) {
        return;
    }
    s_active = NO;
    [[FBFrameMonitor shared] stopMonitoring];
    [FBOverlayView.shared hideOverlay];
}

static void FBApply(void) {
    [[FBPreferences shared] reloadFromDisk];
    if (!FBShouldActivate()) {
        FBStop();
        return;
    }
    if (!s_active) {
        FBStart();
        return;
    }
    if ([FBPreferences shared].overlayEnabled) {
        [FBOverlayView.shared showOverlay];
        [FBOverlayView.shared applyPreferences];
    } else {
        [FBOverlayView.shared hideOverlay];
    }
}

static void _onActive(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    dispatch_async(dispatch_get_main_queue(), ^{
        FBApply();
    });
}

static void _onResign(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    dispatch_async(dispatch_get_main_queue(), ^{
        FBStop();
    });
}

static void _onTerminate(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    dispatch_async(dispatch_get_main_queue(), ^{
        FBStop();
        [[FBStutterLog shared] writeReportToDocuments];
        if (s_token != NOTIFY_TOKEN_INVALID) {
            notify_cancel(s_token);
            s_token = NOTIFY_TOKEN_INVALID;
        }
    });
}

%ctor {
    @autoreleasepool {
        NSString *bundleID = FBBundleID();
        NSArray *blocked = @[
            @"com.apple.springboard",
            @"com.apple.backboardd",
            @"com.apple.cfprefsd",
            @"com.apple.lsd",
            @"com.apple.mediaserverd",
            @"com.apple.xpc.cloudd"
        ];
        for (NSString *blockedID in blocked) {
            if ([bundleID isEqualToString:blockedID]) {
                return;
            }
        }

        [[FBPreferences shared] reloadFromDisk];

        notify_register_dispatch("com.bluexdeev25432.frameboost/reload", &s_token, dispatch_get_main_queue(), ^(int token) {
            dispatch_async(dispatch_get_main_queue(), ^{
                FBApply();
            });
        });

        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), (void *)1, _onActive, CFSTR("UIApplicationDidBecomeActiveNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), (void *)2, _onResign, CFSTR("UIApplicationWillResignActiveNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), (void *)3, _onTerminate, CFSTR("UIApplicationWillTerminateNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            FBApply();
        });
    }
}
