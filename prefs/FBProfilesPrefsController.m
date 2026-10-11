#import "FBProfilesPrefsController.h"

@implementation FBProfilesPrefsController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Profiles" target:self];
    }
    return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];
    NSInteger profile = [value integerValue];
    switch (profile) {
        case 0:
            FBPrefSet(@"updateInterval", @(1.0));
            break;
        case 1:
            FBPrefSet(@"updateInterval", @(0.5));
            break;
        case 2:
            FBPrefSet(@"updateInterval", @(0.2));
            break;
        default:
            break;
    }
}
@end
