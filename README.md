# React Native Cookies - A Cookie Manager for React Native

Cookie Manager for React Native

This module was ported from [joeferraro/react-native-cookies](https://github.com/joeferraro/react-native-cookies). This would not exist without the work of the original author, [Joe Ferraro](https://github.com/joeferraro).

## What's new

- ✅ iOS ネイティブ実装を Swift へ全面移行しました。`ios/Shared` にロジックを集約し、`ios/Legacy` / `ios/NewArchitecture` で旧アーキテクチャと TurboModule を切り替えます。Podspec はこれらのパスをビルド対象に含むよう更新されています。
- ✅ Android も Kotlin 化し、従来の Java 実装で提供していた機能・例外処理をそのまま移植しています。TurboModule 対応のパッケージも Kotlin で提供します。
- ✅ React Native 0.73 以降を前提とすることで、新アーキテクチャを既定で有効にした環境に合わせています。
- ✅ GitHub Actions を導入し、Lint / Android 単体テスト / iOS シミュレータテストを自動実行できるようになりました。
- ✅ Android/iOS 双方にユニットテストを追加し、ドメイン検証や Cookie 属性の保持など重要なケースを自動検証します。

## Important notices & Breaking Changes
- **v6.0.0**: Package name updated to `@react-native-cookies/cookies`.
- **v5.0.0**: Peer Dependency of >= React Native 0.60.2
- **v4.0.0**: Android SDK version bumpted to 21
- **v3.0.0**: Remove React Native Core dependencies, CookieManager.set() support for Android
- **v2.0.0**: Package name updated to `@react-native-community/cookies`.

## Maintainers



## Platforms Supported

- ✅ iOS (Swift + TurboModule 対応)
- ✅ Android (Kotlin + TurboModule 対応)
- ❌ Currently lacking support for Windows, macOS, and web. Support for these platforms will be created when there is a need for them. Starts with a posted issue.

## Expo

- ✅ You can use this library with [Development Builds](https://docs.expo.dev/development/introduction/). No config plugin is required.
- ❌ This library can't be used in the "Expo Go" app because it [requires custom native code](https://docs.expo.dev/workflow/customizing/).

## Installation

```
yarn add @react-native-cookies/cookies
```

Then link the native iOS package

```
npx pod-install
```

### Minimum Requirements

- React Native >= **0.73** (New Architecture が標準有効のため)
- Android Gradle Plugin 3.5.x ＋ Kotlin Gradle Plugin（ライブラリ側に組み込み済み）
- iOS 11+（WebKit Cookie Store 対応）

## Usage

A cookie object can have one of the following fields:

```typescript
export interface Cookie {
  name: string;
  value: string;
  path?: string;
  domain?: string;
  version?: string;
  expires?: string;
  secure?: boolean;
  httpOnly?: boolean;
}

export interface Cookies {
  [key: string]: Cookie;
}
```

```javascript
import CookieManager from '@react-native-cookies/cookies';

// set a cookie
CookieManager.set('http://example.com', {
  name: 'myCookie',
  value: 'myValue',
  domain: 'some domain',
  path: '/',
  version: '1',
  expires: '2015-05-30T12:30:00.00-05:00'
}).then((done) => {
  console.log('CookieManager.set =>', done);
});

*NB:* When no `domain` is specified, url host will be used instead.
*NB:* When no `path` is specified, an empty path `/` will be assumed.

// Set cookies from a response header
// This allows you to put the full string provided by a server's Set-Cookie
// response header directly into the cookie store.
CookieManager.setFromResponse(
  'http://example.com',
  'user_session=abcdefg; path=/; expires=Thu, 1 Jan 2030 00:00:00 -0000; secure; HttpOnly')
    .then((success) => {
      console.log('CookieManager.setFromResponse =>', success);
    });

// Get cookies for a url
CookieManager.get('http://example.com')
  .then((cookies) => {
    console.log('CookieManager.get =>', cookies);
  });

// list cookies (IOS ONLY)
CookieManager.getAll()
  .then((cookies) => {
    console.log('CookieManager.getAll =>', cookies);
  });

// clear cookies
CookieManager.clearAll()
  .then((success) => {
    console.log('CookieManager.clearAll =>', success);
  });

// clear a specific cookie by its name (IOS ONLY)
CookieManager.clearByName('http://example.com', 'cookie_name')
  .then((success) => {
    console.log('CookieManager.clearByName =>', success);
  });

// flush cookies (ANDROID ONLY)
CookieManager.flush()
  .then((success) => {
    console.log('CookieManager.flush =>', success);
  });

// Remove session cookies (ANDROID ONLY)
// Session cookies are cookies with no expires set. Android typically does not
// remove these, it is up to the developer to decide when to remove them.
// The return value is true if any session cookies were removed.
// iOS handles removal of session cookies automatically on app open.
CookieManager.removeSessionCookies()
  .then((sessionCookiesRemoved) => {
    console.log('CookieManager.removeSessionCookies =>', sessionCookiesRemoved);
  });
```

### WebKit-Support (iOS only)

React Native comes with a WebView component, which uses UIWebView on iOS. Introduced in iOS 8 Apple implemented the WebKit-Support with all the performance boost.

Prior to WebKit-Support, cookies would have been stored in `NSHTTPCookieStorage` and sharedCookiesEnabled must be set on webviews to ensure access to them.

With WebKit-Support, cookies are stored in a separate webview store `WKHTTPCookieStore` and not necessarily shared with other http requests. Caveat is that this store is available upon mounting the component but not necessarily prior so any attempts to set a cookie too early may result in a false positive.

To use WebKit-Support, you should be able to simply make advantage of the react-native-webview as is OR alternatively use the webview component like [react-native-wkwebview](https://github.com/CRAlpha/react-native-wkwebview).

To use this _CookieManager_ with WebKit-Support we extended the interface with the attribute `useWebKit` (a boolean value, default: `FALSE`) for the following methods:

| Method      | WebKit-Support | Method-Signature                                                         |
| ----------- | -------------- | ------------------------------------------------------------------------ |
| getAll      | Yes            | `CookieManager.getAll(useWebKit:boolean)`                                |
| clearAll    | Yes            | `CookieManager.clearAll(useWebKit:boolean)`                              |
| clearByName | Yes            | `CookieManager.clearByName(url:string, name: string, useWebKit:boolean)` |
| get         | Yes            | `CookieManager.get(url:string, useWebKit:boolean)`                       |
| set         | Yes            | `CookieManager.set(url:string, cookie:object, useWebKit:boolean)`        |

##### Usage

```javascript
import CookieManager from '@react-native-cookies/cookies';

const useWebKit = true;

// list cookies (IOS ONLY)
CookieManager.getAll(useWebKit)
	.then((cookies) => {
		console.log('CookieManager.getAll from webkit-view =>', cookies);
	});

// clear cookies
CookieManager.clearAll(useWebKit)
	.then((succcess) => {
		console.log('CookieManager.clearAll from webkit-view =>', succcess);
	});

// clear cookies with name (IOS ONLY)
CookieManager.clearByName('http://example.com', 'cookie name', useWebKit)
	.then((succcess) => {
		console.log('CookieManager.clearByName from webkit-view =>', succcess);
  });

// Get cookies as a request header string
CookieManager.get('http://example.com', useWebKit)
	.then((cookies) => {
		console.log('CookieManager.get from webkit-view =>', cookies);
	});

// set a cookie
const newCookie = {
	name: 'myCookie',
	value: 'myValue',
	domain: 'some domain',
	path: '/',
	version: '1',
	expires: '2015-05-30T12:30:00.00-05:00'
};

CookieManager.set('http://example.com', newCookie, useWebKit)
	.then((res) => {
		console.log('CookieManager.set from webkit-view =>', res);
	});
```

## Development

### Lint

```
yarn lint
```

### Android Unit Tests

```
(cd android && ./gradlew test)
```

### iOS Unit Tests

```
xcodebuild \
  -project ios/RNCookieManagerIOS.xcodeproj \
  -scheme RNCookieManagerIOS \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 14' \
  test \
  CODE_SIGNING_ALLOWED=NO
```

### Continuous Integration

GitHub Actions（`.github/workflows/ci.yml`）では以下を自動実行します。

1. **Lint**: Node.js 18 + yarn で ESLint.
2. **Android tests**: Java 11 + Gradle で `./gradlew test`.
3. **iOS tests**: macOS 上で `xcodebuild test` (iPhone 14 シミュレータ).

Pull Request 時にすべて成功していることを確認してください。

