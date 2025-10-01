package com.reactnativecommunity.cookies

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap

/**
 * Legacy architecture bridge module. All functionality lives in [CookieManagerModuleImpl].
 */
class CookieManagerModule(context: ReactApplicationContext) : ReactContextBaseJavaModule(context) {

    private val moduleImpl = CookieManagerModuleImpl(context)

    override fun getName(): String = moduleImpl.getName()

    @ReactMethod
    fun set(url: String, cookie: ReadableMap, useWebKit: Boolean?, promise: Promise) {
        moduleImpl.set(url, cookie, useWebKit, promise)
    }

    @ReactMethod
    fun setFromResponse(url: String, cookie: String?, promise: Promise) {
        moduleImpl.setFromResponse(url, cookie, promise)
    }

    @ReactMethod
    fun flush(promise: Promise) {
        moduleImpl.flush(promise)
    }

    @ReactMethod
    fun removeSessionCookies(promise: Promise) {
        moduleImpl.removeSessionCookies(promise)
    }

    @ReactMethod
    fun getFromResponse(url: String, promise: Promise) {
        try {
            moduleImpl.getFromResponse(url, promise)
        } catch (exception: Exception) {
            promise.reject(exception)
        }
    }

    @ReactMethod
    fun getAll(useWebKit: Boolean?, promise: Promise) {
        moduleImpl.getAll(useWebKit, promise)
    }

    @ReactMethod
    fun get(url: String, useWebKit: Boolean?, promise: Promise) {
        moduleImpl.get(url, useWebKit, promise)
    }

    @ReactMethod
    fun clearByName(url: String, name: String, useWebKit: Boolean?, promise: Promise) {
        moduleImpl.clearByName(url, name, useWebKit, promise)
    }

    @ReactMethod
    fun clearAll(useWebKit: Boolean?, promise: Promise) {
        moduleImpl.clearAll(useWebKit, promise)
    }
}