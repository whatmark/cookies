#import <React/RCTDefines.h>
#import <React/RCTBridgeModule.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <ReactCommon/RCTTurboModule.h>

@interface CookieManagerModule : NSObject <RCTBridgeModule, RCTTurboModule>
@end
#endif

