package com.reactnativecommunity.cookies

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = CookieManagerModuleImpl.NAME)
class CookieManagerModule(context: ReactApplicationContext) : NativeCookieManagerSpec(context) {

    private val moduleImpl = CookieManagerModuleImpl(context)

    override fun getName(): String = moduleImpl.getName()

    override fun set(url: String, cookie: ReadableMap, useWebKit: Boolean?, promise: Promise) {
        moduleImpl.set(url, cookie, useWebKit, promise)
    }

    override fun setFromResponse(url: String, cookie: String?, promise: Promise) {
        moduleImpl.setFromResponse(url, cookie, promise)
    }

    override fun flush(promise: Promise) {
        moduleImpl.flush(promise)
    }

    override fun removeSessionCookies(promise: Promise) {
        moduleImpl.removeSessionCookies(promise)
    }

    override fun getFromResponse(url: String, promise: Promise) {
        moduleImpl.getFromResponse(url, promise)
    }

    override fun getAll(useWebKit: Boolean?, promise: Promise) {
        moduleImpl.getAll(useWebKit, promise)
    }

    override fun get(url: String, useWebKit: Boolean?, promise: Promise) {
        moduleImpl.get(url, useWebKit, promise)
    }

    override fun clearByName(url: String, name: String, useWebKit: Boolean?, promise: Promise) {
        moduleImpl.clearByName(url, name, useWebKit, promise)
    }

    override fun clearAll(useWebKit: Boolean?, promise: Promise) {
        moduleImpl.clearAll(useWebKit, promise)
    }
}