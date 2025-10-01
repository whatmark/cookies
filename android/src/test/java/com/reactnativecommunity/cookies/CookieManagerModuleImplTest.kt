package com.reactnativecommunity.cookies

import com.facebook.react.bridge.JavaOnlyMap
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test
import java.lang.reflect.InvocationTargetException
import java.net.HttpCookie

class CookieManagerModuleImplTest {
    private val module = CookieManagerModuleImpl(null)

    @Test
    fun makeHttpCookieObjectThrowsWhenDomainMismatched() {
        val cookie: ReadableMap = JavaOnlyMap.of(
            "name", "session",
            "value", "value",
            "domain", "other.com"
        )

        val method = CookieManagerModuleImpl::class.java.getDeclaredMethod(
            "makeHTTPCookieObject",
            String::class.java,
            ReadableMap::class.java
        ).apply { isAccessible = true }

        try {
            method.invoke(module, "https://example.com", cookie)
            fail("Expected an exception to be thrown")
        } catch (exception: InvocationTargetException) {
            val cause = exception.cause
            assertNotNull(cause)
            assertTrue(cause.message?.contains("mismatched") == true)
        }
    }

    @Test
    fun createCookieDataIncludesSecureAndHttpOnly() {
        val cookie = HttpCookie("name", "value").apply {
            domain = "example.com"
            path = "/"
            secure = true
            isHttpOnly = true
        }

        val method = CookieManagerModuleImpl::class.java.getDeclaredMethod(
            "createCookieData",
            HttpCookie::class.java
        ).apply { isAccessible = true }

        val result = method.invoke(module, cookie) as WritableMap
        assertEquals("name", result.getString("name"))
        assertEquals("value", result.getString("value"))
        assertTrue(result.getBoolean("secure"))
        assertTrue(result.getBoolean("httpOnly"))
    }

    @Test
    fun toRfc6265StringIncludesAttributes() {
        val cookie = HttpCookie("name", "value").apply {
            domain = "example.com"
            path = "/"
            secure = true
            isHttpOnly = true
        }

        val method = CookieManagerModuleImpl::class.java.getDeclaredMethod(
            "toRFC6265string",
            HttpCookie::class.java
        ).apply { isAccessible = true }

        val value = method.invoke(module, cookie) as String
        assertTrue(value.contains("name=value"))
        assertTrue(value.contains("domain=example.com"))
        assertTrue(value.contains("path=/"))
        assertTrue(value.contains("secure"))
        assertTrue(value.lowercase().contains("httponly"))
    }
}
