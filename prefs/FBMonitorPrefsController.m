#import "FBMonitorPrefsController.h"

@implementation FBMonitorPrefsController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Monitor" target:self];
    }
    return _specifiers;
}
@end
