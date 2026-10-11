#import "FBPreferences.h"

NSString *const kFBDomain = @"com.bluexdeev25432.frameboost";
NSString *const kFBNotifyReload = @"com.bluexdeev25432.frameboost/reload";

static UIColor *FBHexColorFromString(NSString *hexString) {
    NSString *clean = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([clean hasPrefix:@"#"]) {
        clean = [clean substringFromIndex:1];
    }
    if (clean.length == 6) {
        unsigned int value = 0;
        NSScanner *scanner = [NSScanner scannerWithString:clean];
        if ([scanner scanHexInt:&value]) {
            CGFloat r = ((value >> 16) & 0xFF) / 255.0;
            CGFloat g = ((value >> 8) & 0xFF) / 255.0;
            CGFloat b = (value & 0xFF) / 255.0;
            return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        }
    }
    return [UIColor colorWithRed:0.0 green:1.0 blue:0.533333 alpha:1.0];
}

@implementation FBPreferences {
    dispatch_queue_t _reloadQueue;
}

+ (instancetype)shared {
    static FBPreferences *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FBPreferences alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _reloadQueue = dispatch_queue_create("com.bluexdeev25432.frameboost.prefs", DISPATCH_QUEUE_SERIAL);
        [self reloadFromDisk];
    }
    return self;
}

- (void)reloadFromDisk {
    __block BOOL tweakEnabled = YES;
    __block BOOL overlayEnabled = YES;
    __block double updateInterval = 0.5;
    __block double stutterThresholdMS = 33.3;
    __block CGFloat overlayX = 8.0;
    __block CGFloat overlayY = 60.0;
    __block CGFloat fontSize = 12.0;
    __block CGFloat bgAlpha = 0.55;
    __block BOOL showFrametime = YES;
    __block NSInteger perfProfile = 1;
    __block UIColor *textColor = FBHexColorFromString(@"#00FF88");
    __block NSArray<NSString *> *allowedBundleIDs = @[];

    CFTypeRef value = CFPreferencesCopyValue(CFSTR("enabled"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        tweakEnabled = [(__bridge NSNumber *)value boolValue];
        CFRelease(value);
    }

    value = CFPreferencesCopyValue(CFSTR("overlayEnabled"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        overlayEnabled = [(__bridge NSNumber *)value boolValue];
        CFRelease(value);
    }

    value = CFPreferencesCopyValue(CFSTR("updateInterval"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        updateInterval = [(__bridge NSNumber *)value doubleValue];
        CFRelease(value);
    }
    if (updateInterval < 0.1) {
        updateInterval = 0.1;
    }

    value = CFPreferencesCopyValue(CFSTR("stutterThresholdMS"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        stutterThresholdMS = [(__bridge NSNumber *)value doubleValue];
        CFRelease(value);
    }
    if (stutterThresholdMS < 1.0) {
        stutterThresholdMS = 1.0;
    }

    value = CFPreferencesCopyValue(CFSTR("overlayX"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        overlayX = [(__bridge NSNumber *)value doubleValue];
        CFRelease(value);
    }

    value = CFPreferencesCopyValue(CFSTR("overlayY"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        overlayY = [(__bridge NSNumber *)value doubleValue];
        CFRelease(value);
    }

    value = CFPreferencesCopyValue(CFSTR("fontSize"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        fontSize = [(__bridge NSNumber *)value doubleValue];
        CFRelease(value);
    }
    if (fontSize < 8.0) {
        fontSize = 8.0;
    }

    value = CFPreferencesCopyValue(CFSTR("bgAlpha"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        bgAlpha = [(__bridge NSNumber *)value doubleValue];
        CFRelease(value);
    }

    value = CFPreferencesCopyValue(CFSTR("showFrametime"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        showFrametime = [(__bridge NSNumber *)value boolValue];
        CFRelease(value);
    }

    value = CFPreferencesCopyValue(CFSTR("perfProfile"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        perfProfile = [(__bridge NSNumber *)value integerValue];
        CFRelease(value);
    }

    value = CFPreferencesCopyValue(CFSTR("textColorHex"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        NSString *hex = CFBridgingRelease(value);
        if ([hex isKindOfClass:[NSString class]]) {
            textColor = FBHexColorFromString(hex);
        }
    }

    value = CFPreferencesCopyValue(CFSTR("allowedBundleIDs"), (__bridge CFStringRef)kFBDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        NSArray *arr = CFBridgingRelease(value);
        if ([arr isKindOfClass:[NSArray class]]) {
            allowedBundleIDs = arr;
        }
    }

    dispatch_sync(_reloadQueue, ^{
        self.tweakEnabled = tweakEnabled;
        self.overlayEnabled = overlayEnabled;
        self.updateInterval = updateInterval;
        self.stutterThresholdMS = stutterThresholdMS;
        self.overlayX = overlayX;
        self.overlayY = overlayY;
        self.fontSize = fontSize;
        self.bgAlpha = bgAlpha;
        self.showFrametime = showFrametime;
        self.perfProfile = perfProfile;
        self.textColor = textColor;
        self.allowedBundleIDs = allowedBundleIDs;
    });
}

- (BOOL)isBundleIDAllowed:(NSString *)bundleID {
    if (!self.tweakEnabled) {
        return NO;
    }
    if (self.allowedBundleIDs.count == 0) {
        return YES;
    }
    return [self.allowedBundleIDs containsObject:bundleID];
}

@end
