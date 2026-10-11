#import "FBDiagnosticsController.h"
#import <notify.h>

@implementation FBDiagnosticsController

- (NSArray *)specifiers {
    if (_specifiers) {
        return _specifiers;
    }

    NSMutableArray *specifiers = [NSMutableArray array];

    PSSpecifier *infoGroup = [PSSpecifier preferenceSpecifierNamed:@"Tweak Info" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [specifiers addObject:infoGroup];

    PSSpecifier *version = [PSSpecifier preferenceSpecifierNamed:@"Version" target:self set:nil get:@selector(readPreferenceValue:) detail:nil cell:PSStaticTextCell edit:nil];
    [version setProperty:@(FBVERSION) forKey:@"value"];
    [specifiers addObject:version];

    PSSpecifier *domain = [PSSpecifier preferenceSpecifierNamed:@"Domain" target:self set:nil get:@selector(readPreferenceValue:) detail:nil cell:PSStaticTextCell edit:nil];
    [domain setProperty:@FB_DOMAIN forKey:@"value"];
    [specifiers addObject:domain];

    PSSpecifier *actionGroup = [PSSpecifier preferenceSpecifierNamed:@"Actions" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [specifiers addObject:actionGroup];

    PSSpecifier *resetAction = [PSSpecifier preferenceSpecifierNamed:@"Reset All Preferences" target:self set:@selector(actionReset) get:nil detail:nil cell:PSButtonCell edit:nil];
    [specifiers addObject:resetAction];

    PSSpecifier *logPath = [PSSpecifier preferenceSpecifierNamed:@"Log Path" target:self set:nil get:@selector(readPreferenceValue:) detail:nil cell:PSStaticTextCell edit:nil];
    [logPath setProperty:@"/var/mobile/Documents/frameboost_stutter.log" forKey:@"value"];
    [specifiers addObject:logPath];

    _specifiers = specifiers;
    return _specifiers;
}

- (void)actionReset {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Reset preferences" message:@"This removes FrameBoost settings and reloads the tweak." preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        CFPreferencesSetMultiple(
            NULL,
            (__bridge CFArrayRef)@[
                @"enabled",
                @"overlayEnabled",
                @"updateInterval",
                @"stutterThresholdMS",
                @"overlayX",
                @"overlayY",
                @"fontSize",
                @"textColorHex",
                @"bgAlpha",
                @"showFrametime",
                @"perfProfile",
                @"allowedBundleIDs"
            ],
            CFSTR(FB_DOMAIN),
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        );
        CFPreferencesAppSynchronize(CFSTR(FB_DOMAIN));
        notify_post(FB_NOTIFY);
    }];
    [controller addAction:cancelAction];
    [controller addAction:resetAction];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
