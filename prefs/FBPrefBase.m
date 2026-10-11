#import "FBPrefBase.h"
#import <notify.h>
#import <CoreFoundation/CoreFoundation.h>

void FBPrefSet(NSString *key, id value) {
    CFPreferencesSetValue((CFStringRef)key, (__bridge CFPropertyListRef)value, CFSTR(FB_DOMAIN), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPreferencesAppSynchronize(CFSTR(FB_DOMAIN));
    notify_post(FB_NOTIFY);
}

id FBPrefGet(NSString *key, id defaultValue) {
    CFTypeRef value = CFPreferencesCopyValue((CFStringRef)key, CFSTR(FB_DOMAIN), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value == NULL) {
        return defaultValue;
    }
    return CFBridgingRelease(value);
}

@implementation FBBaseListController

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = specifier.properties[@"key"];
    if (key != nil) {
        FBPrefSet(key, value);
    }
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = specifier.properties[@"key"];
    id def = specifier.properties[@"default"];
    if (key == nil) {
        return def;
    }
    return FBPrefGet(key, def);
}

@end
