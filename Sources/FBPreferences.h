#pragma once
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kFBDomain;
extern NSString *const kFBNotifyReload;

@interface FBPreferences : NSObject
+ (instancetype)shared;
- (void)reloadFromDisk;
@property (atomic, assign) BOOL    tweakEnabled;
@property (atomic, assign) BOOL    overlayEnabled;
@property (atomic, assign) double  updateInterval;
@property (atomic, assign) double  stutterThresholdMS;
@property (atomic, assign) CGFloat overlayX;
@property (atomic, assign) CGFloat overlayY;
@property (atomic, assign) CGFloat fontSize;
@property (atomic, assign) CGFloat bgAlpha;
@property (atomic, assign) BOOL    showFrametime;
@property (atomic, assign) NSInteger perfProfile;
@property (atomic, copy)   UIColor *textColor;
@property (atomic, copy)   NSArray<NSString *> *allowedBundleIDs;
- (BOOL)isBundleIDAllowed:(NSString *)bundleID;
@end

NS_ASSUME_NONNULL_END
