#pragma once
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBStutterLog : NSObject
+ (instancetype)shared;
- (void)recordFrametimeMS:(double)ms threshold:(double)threshold;
- (void)clearLog;
- (NSString *)exportReport;
- (void)writeReportToDocuments;
@property (nonatomic, readonly) NSUInteger totalStutterCount;
@end

NS_ASSUME_NONNULL_END
