#import "FBOverlayPrefsController.h"

@implementation FBOverlayPrefsController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Overlay" target:self];
    }
    return _specifiers;
}
@end
