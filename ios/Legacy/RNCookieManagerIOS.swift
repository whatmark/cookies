import Foundation
import React

#if !RCT_NEW_ARCH_ENABLED
@objc(RNCookieManagerIOS)
final class RNCookieManagerIOS: NSObject, RCTBridgeModule {
    private let moduleImpl = CookieManagerModuleImpl()

    static func moduleName() -> String! {
        return CookieManagerModuleImpl().moduleName()
    }

    static func requiresMainQueueSetup() -> Bool {
        return false
    }

    @objc
    func set(_ url: URL,
             cookie: NSDictionary,
             useWebKit: Bool,
             resolver: @escaping RCTPromiseResolveBlock,
             rejecter: @escaping RCTPromiseRejectBlock) {
        moduleImpl.set(url: url, cookie: cookie, useWebKit: useWebKit, resolver: resolver, rejecter: rejecter)
    }

    @objc
    func setFromResponse(_ url: URL,
                         cookie: String?,
                         resolver: @escaping RCTPromiseResolveBlock,
                         rejecter: @escaping RCTPromiseRejectBlock) {
        moduleImpl.setFromResponse(url: url, cookie: cookie, resolver: resolver, rejecter: rejecter)
    }

    @objc
    func getFromResponse(_ url: URL,
                         resolver: @escaping RCTPromiseResolveBlock,
                         rejecter: @escaping RCTPromiseRejectBlock) {
        moduleImpl.getFromResponse(url: url, resolver: resolver, rejecter: rejecter)
    }

    @objc
    func get(_ url: URL,
             useWebKit: Bool,
             resolver: @escaping RCTPromiseResolveBlock,
             rejecter: @escaping RCTPromiseRejectBlock) {
        moduleImpl.get(url: url, useWebKit: useWebKit, resolver: resolver, rejecter: rejecter)
    }

    @objc
    func clearAll(_ useWebKit: Bool,
                  resolver: @escaping RCTPromiseResolveBlock,
                  rejecter: @escaping RCTPromiseRejectBlock) {
        moduleImpl.clearAll(useWebKit: useWebKit, resolver: resolver, rejecter: rejecter)
    }

    @objc
    func clearByName(_ url: URL,
                     name: String,
                     useWebKit: Bool,
                     resolver: @escaping RCTPromiseResolveBlock,
                     rejecter: @escaping RCTPromiseRejectBlock) {
        moduleImpl.clearByName(url: url, name: name, useWebKit: useWebKit, resolver: resolver, rejecter: rejecter)
    }

    @objc
    func getAll(_ useWebKit: Bool,
                resolver: @escaping RCTPromiseResolveBlock,
                rejecter: @escaping RCTPromiseRejectBlock) {
        moduleImpl.getAll(useWebKit: useWebKit, resolver: resolver, rejecter: rejecter)
    }
}
#endif