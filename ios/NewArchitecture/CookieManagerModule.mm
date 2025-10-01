#ifdef RCT_NEW_ARCH_ENABLED

#import "CookieManagerModule.h"

#import <React/RCTBridge+Private.h>
#import <ReactCommon/ReactTurboModule.h>
#import "react_native_cookies-Swift.h"

using namespace facebook::react;

@implementation CookieManagerModule {
    CookieManagerModuleImpl *_moduleImpl;
}

@synthesize bridge = _bridge;
@synthesize moduleRegistry = _moduleRegistry;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _moduleImpl = [CookieManagerModuleImpl new];
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

RCT_EXPORT_MODULE(RNCookieManagerIOS)

- (std::shared_ptr<TurboModule>)getTurboModule:(const ObjCTurboModule::InitParams &)params
{
    return std::make_shared<ObjCTurboModule>(params, self);
}

RCT_EXPORT_METHOD(
    set:(NSURL *)url
    cookie:(NSDictionary *)props
    useWebKit:(BOOL)useWebKit
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject)
{
    [_moduleImpl setWithUrl:url cookie:props useWebKit:useWebKit resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(
    setFromResponse:(NSURL *)url
    cookie:(NSString *)cookie
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject)
{
    [_moduleImpl setFromResponseWithUrl:url cookie:cookie resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(
    getFromResponse:(NSURL *)url
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject)
{
    [_moduleImpl getFromResponseWithUrl:url resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(
    get:(NSURL *)url
    useWebKit:(BOOL)useWebKit
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject)
{
    [_moduleImpl getWithUrl:url useWebKit:useWebKit resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(
    clearAll:(BOOL)useWebKit
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject)
{
    [_moduleImpl clearAllWithUseWebKit:useWebKit resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(
    clearByName:(NSURL *)url
    name:(NSString *)name
    useWebKit:(BOOL)useWebKit
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject)
{
    [_moduleImpl clearByNameWithUrl:url name:name useWebKit:useWebKit resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(
    getAll:(BOOL)useWebKit
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject)
{
    [_moduleImpl getAllWithUseWebKit:useWebKit resolver:resolve rejecter:reject];
}

@end

#endif