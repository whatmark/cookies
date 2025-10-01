package com.reactnativecommunity.cookies

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReactModuleWithSpec
import com.facebook.react.turbomodule.core.interfaces.TurboModule

abstract class NativeCookieManagerSpec(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext), ReactModuleWithSpec, TurboModule {

    @ReactMethod
    abstract fun set(url: String, cookie: ReadableMap, useWebKit: Boolean?, promise: Promise)

    @ReactMethod
    abstract fun setFromResponse(url: String, cookie: String?, promise: Promise)

    @ReactMethod
    abstract fun flush(promise: Promise)

    @ReactMethod
    abstract fun removeSessionCookies(promise: Promise)

    @ReactMethod
    abstract fun getFromResponse(url: String, promise: Promise)

    @ReactMethod
    abstract fun getAll(useWebKit: Boolean?, promise: Promise)

    @ReactMethod
    abstract fun get(url: String, useWebKit: Boolean?, promise: Promise)

    @ReactMethod
    abstract fun clearByName(url: String, name: String, useWebKit: Boolean?, promise: Promise)

    @ReactMethod
    abstract fun clearAll(useWebKit: Boolean?, promise: Promise)
}