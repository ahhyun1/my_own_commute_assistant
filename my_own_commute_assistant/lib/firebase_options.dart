import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBKT2uCp0PgYIL7YJUpqDLFN-fNErqukmM',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_WEB_MESSAGING_SENDER_ID',
    projectId: 'my-own-commute-assistant-6cdae',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKT2uCp0PgYIL7YJUpqDLFN-fNErqukmM',
    appId: '1:487305311953:android:0620373241a9dfa213b7f0',
    messagingSenderId: '487305311953',
    projectId: 'my-own-commute-assistant-6cdae',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3h9ILzul3r8WU-eAuAcVJ_lkO8f3nPYI',
    appId: '1:487305311953:ios:30bef2f7f9ebb30d13b7f0',
    messagingSenderId: '487305311953',
    projectId: 'my-own-commute-assistant-6cdae',
    storageBucket: 'my-own-commute-assistant-6cdae.appspot.com',
    iosBundleId: 'com.example.myOwnCommuteAssistant',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MACOS_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    iosBundleId: 'YOUR_MACOS_BUNDLE_ID',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_WINDOWS_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'YOUR_LINUX_API_KEY',
    appId: 'YOUR_LINUX_APP_ID',
    messagingSenderId: 'YOUR_LINUX_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
  );
}