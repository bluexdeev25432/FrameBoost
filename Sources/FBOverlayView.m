#import "FBOverlayView.h"
#import "FBPreferences.h"

@interface FBPassWindow : UIWindow
@end

@implementation FBPassWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}
@end

@interface FBRootVC : UIViewController
@end

@implementation FBRootVC
- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = NO;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}
@end

@implementation FBOverlayView {
    UILabel *_fpsLabel;
    FBPassWindow *_window;
    BOOL _isVisible;
}

+ (instancetype)shared {
    static FBOverlayView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FBOverlayView alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = NO;

        _fpsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _fpsLabel.numberOfLines = 2;
        _fpsLabel.userInteractionEnabled = NO;
        _fpsLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_fpsLabel];

        _isVisible = NO;
    }
    return self;
}

- (BOOL)isVisible {
    return _isVisible;
}

- (void)_buildWindow {
    if (_window) {
        return;
    }

    Class UIWindowSceneClass = NSClassFromString(@"UIWindowScene");
    if (UIWindowSceneClass != nil) {
        id scene = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        for (id candidate in UIApplication.sharedApplication.connectedScenes) {
            if ([candidate isKindOfClass:UIWindowSceneClass]) {
                SEL activationStateSelector = NSSelectorFromString(@"activationState");
                if ([candidate respondsToSelector:activationStateSelector]) {
                    NSInteger activationState = (NSInteger)[candidate performSelector:activationStateSelector];
                    if (activationState == 0) {
                        scene = candidate;
                        break;
                    }
                }
            }
        }
#pragma clang diagnostic pop
        if (!scene) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
            for (id candidate in UIApplication.sharedApplication.connectedScenes) {
                if ([candidate isKindOfClass:UIWindowSceneClass]) {
                    scene = candidate;
                    break;
                }
            }
#pragma clang diagnostic pop
        }
        if (scene) {
            SEL initWithWindowSceneSelector = NSSelectorFromString(@"initWithWindowScene:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([FBPassWindow instancesRespondToSelector:initWithWindowSceneSelector]) {
                _window = [[FBPassWindow alloc] performSelector:initWithWindowSceneSelector withObject:scene];
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                _window = [[FBPassWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
#pragma clang diagnostic pop
            }
#pragma clang diagnostic pop
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _window = [[FBPassWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
#pragma clang diagnostic pop
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _window = [[FBPassWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
#pragma clang diagnostic pop
    }

    _window.windowLevel = UIWindowLevelStatusBar + 200.0;
    _window.backgroundColor = [UIColor clearColor];
    _window.userInteractionEnabled = NO;
    _window.hidden = YES;

    FBRootVC *rootVC = [[FBRootVC alloc] init];
    _window.rootViewController = rootVC;
    [rootVC.view addSubview:self];
}

- (void)showOverlay {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showOverlay];
        });
        return;
    }

    if (!_window) {
        [self _buildWindow];
    }

    [self applyPreferences];
    _window.hidden = NO;
    _isVisible = YES;
}

- (void)hideOverlay {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideOverlay];
        });
        return;
    }

    if (_window) {
        _window.hidden = YES;
    }
    _isVisible = NO;
}

- (void)updateWithStats:(FBFrameStats)stats {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateWithStats:stats];
        });
        return;
    }

    if (!_isVisible) {
        return;
    }

    FBPreferences *prefs = [FBPreferences shared];
    NSString *text = [NSString stringWithFormat:@"FPS: %.0f", stats.currentFPS];
    if (prefs.showFrametime) {
        text = [text stringByAppendingFormat:@"\n%.2f ms", stats.currentFrametimeMS];
    }
    _fpsLabel.text = text;

    CGSize labelSize = [_fpsLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat paddingH = 6.0;
    CGFloat paddingV = 4.0;
    CGFloat width = labelSize.width + paddingH * 2.0;
    CGFloat height = labelSize.height + paddingV * 2.0;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
    _fpsLabel.frame = CGRectMake(paddingH, paddingV, labelSize.width, labelSize.height);
}

- (void)applyPreferences {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self applyPreferences];
        });
        return;
    }

    FBPreferences *prefs = [FBPreferences shared];
    self.frame = CGRectMake(prefs.overlayX, prefs.overlayY, self.frame.size.width, self.frame.size.height);
    _fpsLabel.font = [UIFont systemFontOfSize:prefs.fontSize];
    _fpsLabel.textColor = prefs.textColor;
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:prefs.bgAlpha];
}

@end
