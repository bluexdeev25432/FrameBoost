#pragma once
#import <Preferences/Preferences.h>

#define FB_DOMAIN "com.bluexdeev25432.frameboost"
#define FB_NOTIFY "com.bluexdeev25432.frameboost/reload"

void FBPrefSet(NSString *key, id value);
id   FBPrefGet(NSString *key, id defaultValue);

@interface FBBaseListController : PSListController
@end
