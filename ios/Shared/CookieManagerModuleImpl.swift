import Foundation
import React
import WebKit

@objcMembers
final class CookieManagerModuleImpl: NSObject {
    private enum Constants {
        static let moduleName = "RNCookieManagerIOS"
        static let notAvailableMessage = "WebKit/WebKit-Components are only available with iOS11 and higher!"
        static let invalidUrlMessage = "Invalid URL: It may be missing a protocol (ex. http:// or https://)."
        static let invalidCookieValues = "Unable to add cookie - invalid values"
    }

    private enum CookieError: LocalizedError {
        case invalidUrl
        case invalidCookieValues
        case invalidDomains(host: String, domain: String)

        var errorDescription: String? {
            switch self {
            case .invalidUrl:
                return Constants.invalidUrlMessage
            case .invalidCookieValues:
                return Constants.invalidCookieValues
            case let .invalidDomains(host, domain):
                return "Cookie URL host \(host) and domain \(domain) mismatched. The cookie won't set correctly."
            }
        }
    }

    private let formatter: DateFormatter
    private let rfc1123Formatter: DateFormatter

    override init() {
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        rfc1123Formatter = DateFormatter()
        rfc1123Formatter.locale = Locale(identifier: "en_US_POSIX")
        rfc1123Formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        rfc1123Formatter.timeZone = TimeZone(secondsFromGMT: 0)
        super.init()
    }

    func moduleName() -> String {
        return Constants.moduleName
    }

    func set(url: URL,
             cookie: NSDictionary,
             useWebKit: Bool,
             resolver: @escaping RCTPromiseResolveBlock,
             rejecter: @escaping RCTPromiseRejectBlock) {
        do {
            let httpCookie = try makeHTTPCookieObject(url: url, props: cookie)
            set(cookie: httpCookie, for: url, useWebKit: useWebKit, resolver: resolver, rejecter: rejecter)
        } catch {
            rejecter("cookie_error", error.localizedDescription, error as NSError)
        }
    }

    func setFromResponse(url: URL,
                         cookie: String?,
                         resolver: @escaping RCTPromiseResolveBlock,
                         rejecter: @escaping RCTPromiseRejectBlock) {
        guard let cookie = cookie, !cookie.isEmpty else {
            rejecter("cookie_error", Constants.invalidCookieValues, nil)
            return
        }

        let cookies = HTTPCookie.cookies(withResponseHeaderFields: ["Set-Cookie": cookie], for: url)
        HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
        resolver(true)
    }

    func getFromResponse(url: URL,
                         resolver: @escaping RCTPromiseResolveBlock,
                         rejecter: @escaping RCTPromiseRejectBlock) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                rejecter("cookie_error", error.localizedDescription, error)
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                let headerFields = httpResponse.allHeaderFields as? [String: String]
            else {
                rejecter("cookie_error", "Unable to fetch response cookies", nil)
                return
            }

            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            var dictionary: [String: String] = [:]
            cookies.forEach { cookie in
                dictionary[cookie.name] = cookie.value
                HTTPCookieStorage.shared.setCookie(cookie)
            }
            resolver(dictionary)
        }.resume()
    }

    func get(url: URL,
             useWebKit: Bool,
             resolver: @escaping RCTPromiseResolveBlock,
             rejecter: @escaping RCTPromiseRejectBlock) {
        if useWebKit {
            guard #available(iOS 11.0, *) else {
                rejecter("cookie_error", Constants.notAvailableMessage, nil)
                return
            }

            let topLevelDomain = url.host
            guard let host = topLevelDomain, !host.isEmpty else {
                rejecter("cookie_error", Constants.invalidUrlMessage, nil)
                return
            }

            DispatchQueue.main.async {
                WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                    var result: [String: [String: Any]] = [:]
                    for cookie in cookies where host.contains(cookie.domain) || cookie.domain == host {
                        result[cookie.name] = self.createCookieData(cookie)
                    }
                    resolver(result)
                }
            }
        } else {
            var result: [String: [String: Any]] = [:]
            for cookie in HTTPCookieStorage.shared.cookies(for: url) ?? [] {
                result[cookie.name] = createCookieData(cookie)
            }
            resolver(result)
        }
    }

    func clearAll(useWebKit: Bool,
                  resolver: @escaping RCTPromiseResolveBlock,
                  rejecter: @escaping RCTPromiseRejectBlock) {
        if useWebKit {
            guard #available(iOS 11.0, *) else {
                rejecter("cookie_error", Constants.notAvailableMessage, nil)
                return
            }

            DispatchQueue.main.async {
                let types: Set<String> = [WKWebsiteDataTypeCookies]
                let date = Date(timeIntervalSince1970: 0)
                WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: date) {
                    resolver(true)
                }
            }
        } else {
            let storage = HTTPCookieStorage.shared
            storage.cookies?.forEach { storage.deleteCookie($0) }
            UserDefaults.standard.synchronize()
            resolver(true)
        }
    }

    func clearByName(url: URL,
                     name: String,
                     useWebKit: Bool,
                     resolver: @escaping RCTPromiseResolveBlock,
                     rejecter: @escaping RCTPromiseRejectBlock) {
        if useWebKit {
            guard #available(iOS 11.0, *) else {
                rejecter("cookie_error", Constants.notAvailableMessage, nil)
                return
            }

            guard let host = url.host, !host.isEmpty else {
                rejecter("cookie_error", Constants.invalidUrlMessage, nil)
                return
            }

            DispatchQueue.main.async {
                WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                    var found = false
                    let store = WKWebsiteDataStore.default().httpCookieStore
                    let matchingCookies = cookies.filter {
                        $0.name == name && self.isMatchingDomain(originDomain: host, cookieDomain: $0.domain)
                    }
                    if !matchingCookies.isEmpty {
                        found = true
                        matchingCookies.forEach { cookie in
                            store.delete(cookie, completionHandler: nil)
                        }
                    }
                    resolver(found)
                }
            }
        } else {
            let storage = HTTPCookieStorage.shared
            var found = false
            storage.cookies?.forEach { cookie in
                if cookie.name == name && self.isMatchingDomain(originDomain: url.host ?? "", cookieDomain: cookie.domain) {
                    storage.deleteCookie(cookie)
                    found = true
                }
            }
            resolver(found)
        }
    }

    func getAll(useWebKit: Bool,
                resolver: @escaping RCTPromiseResolveBlock,
                rejecter: @escaping RCTPromiseRejectBlock) {
        if useWebKit {
            guard #available(iOS 11.0, *) else {
                rejecter("cookie_error", Constants.notAvailableMessage, nil)
                return
            }

            DispatchQueue.main.async {
                WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                    resolver(self.createCookieList(cookies))
                }
            }
        } else {
            let cookies = HTTPCookieStorage.shared.cookies ?? []
            resolver(createCookieList(cookies))
        }
    }

    private func set(cookie: HTTPCookie,
                     for url: URL,
                     useWebKit: Bool,
                     resolver: @escaping RCTPromiseResolveBlock,
                     rejecter: @escaping RCTPromiseRejectBlock) {
        if useWebKit {
            guard #available(iOS 11.0, *) else {
                rejecter("cookie_error", Constants.notAvailableMessage, nil)
                return
            }

            DispatchQueue.main.async {
                WKWebsiteDataStore.default().httpCookieStore.setCookie(cookie) {
                    resolver(true)
                }
            }
        } else {
            HTTPCookieStorage.shared.setCookie(cookie)
            resolver(true)
        }
    }

    private func makeHTTPCookieObject(url: URL, props: NSDictionary) throws -> HTTPCookie {
        guard let host = url.host, !host.isEmpty else {
            throw CookieError.invalidUrl
        }

        guard
            let name = props["name"] as? String,
            let value = props["value"] as? String
        else {
            throw CookieError.invalidCookieValues
        }

        var cookieProperties: [HTTPCookiePropertyKey: Any] = [
            .name: name,
            .value: value,
            .path: "/"
        ]

        if let path = props["path"] as? String, !path.isEmpty {
            cookieProperties[.path] = path
        }

        if let domain = props["domain"] as? String, !domain.isEmpty {
            let strippedDomain: String
            if domain.hasPrefix(".") {
                strippedDomain = String(domain.dropFirst())
            } else {
                strippedDomain = domain
            }

            if !host.contains(strippedDomain) && host != strippedDomain {
                throw CookieError.invalidDomains(host: host, domain: domain)
            }

            cookieProperties[.domain] = domain
        } else {
            cookieProperties[.domain] = host
        }

        if let version = props["version"] as? String, !version.isEmpty {
            cookieProperties[.version] = version
        }

        if let expiresString = props["expires"] as? String, !expiresString.isEmpty {
            if let date = formatter.date(from: expiresString) {
                cookieProperties[.expires] = date
            }
        }

        if let secure = props["secure"] as? Bool, secure {
            cookieProperties[.secure] = NSNumber(value: true)
        }

        if let httpOnly = props["httpOnly"] as? Bool, httpOnly {
            cookieProperties[HTTPCookiePropertyKey("HttpOnly")] = NSNumber(value: true)
        }

        guard let cookie = HTTPCookie(properties: cookieProperties) else {
            throw CookieError.invalidCookieValues
        }

        return cookie
    }

    private func createCookieList(_ cookies: [HTTPCookie]) -> [String: [String: Any]] {
        var list: [String: [String: Any]] = [:]
        cookies.forEach { cookie in
            list[cookie.name] = createCookieData(cookie)
        }
        return list
    }

    private func createCookieData(_ cookie: HTTPCookie) -> [String: Any] {
        var data: [String: Any] = [
            "name": cookie.name,
            "value": cookie.value,
            "path": cookie.path,
            "domain": cookie.domain,
            "version": String(cookie.version),
            "secure": cookie.isSecure,
            "httpOnly": cookie.isHTTPOnly
        ]

        if let expiresDate = cookie.expiresDate {
            data["expires"] = formatter.string(from: expiresDate)
        }

        return data
    }

    private func isMatchingDomain(originDomain: String, cookieDomain: String) -> Bool {
        if originDomain == cookieDomain {
            return true
        }
        let parentDomain = cookieDomain.hasPrefix(".") ? cookieDomain : "." + cookieDomain
        return originDomain.hasSuffix(parentDomain)
    }
}