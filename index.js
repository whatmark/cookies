/**
 * Copyright (c) Joseph P. Ferraro
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file here: https://github.com/joeferraro/react-native-cookies/blob/master/LICENSE.md.
 */

import { NativeModules, Platform } from 'react-native';
const invariant = require('invariant');
const TurboModuleRegistry =
  global.__turboModuleProxy != null
    ? require('react-native').TurboModuleRegistry
    : null;
const isTurboModuleEnabled = TurboModuleRegistry != null;
const RNCookieManagerIOS =
  Platform.OS === 'ios' && isTurboModuleEnabled
    ? TurboModuleRegistry.getEnforcing('RNCookieManagerIOS')
    : NativeModules.RNCookieManagerIOS;
const RNCookieManagerAndroid =
  Platform.OS === 'android' && isTurboModuleEnabled
    ? TurboModuleRegistry.getEnforcing('RNCookieManagerAndroid')
    : NativeModules.RNCookieManagerAndroid;

let CookieManager;

if (Platform.OS === 'ios') {
  invariant(
    RNCookieManagerIOS,
    '@react-native-community/cookies: Add RNCookieManagerIOS.h and RNCookieManagerIOS.m to your Xcode project',
  );
  CookieManager = RNCookieManagerIOS;
} else if (Platform.OS === 'android') {
  invariant(
    RNCookieManagerAndroid,
    '@react-native-community/cookies: Import libraries to android "react-native link @react-native-community/cookies"',
  );
  CookieManager = RNCookieManagerAndroid;
} else {
  invariant(
    CookieManager,
    '@react-native-community/cookies: Invalid platform. This library only supports Android and iOS.',
  );
}

const functions = ['setFromResponse', 'getFromResponse'];

module.exports = {
  getAll: (useWebKit = false) => CookieManager.getAll(useWebKit),
  clearAll: (useWebKit = false) => CookieManager.clearAll(useWebKit),
  get: (url, useWebKit = false) => CookieManager.get(url, useWebKit),
  set: (url, cookie, useWebKit = false) =>
    CookieManager.set(url, cookie, useWebKit),
  clearByName: (url, name, useWebKit = false) =>
    CookieManager.clearByName(url, name, useWebKit),
  flush: async () => {
    if (Platform.OS === 'android') {
      await CookieManager.flush();
    }
  },
  removeSessionCookies: async () => {
    if (Platform.OS === 'android') {
      return await CookieManager.removeSessionCookies();
    }
  },
};

for (var i = 0; i < functions.length; i++) {
  module.exports[functions[i]] = CookieManager[functions[i]];
}
