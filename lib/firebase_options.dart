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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBVyztjuLav9GXxZnz1qCtfkX6QNxRYyWU',
    appId: '1:559730617790:web:ed32b786f1386062b6ddef',
    messagingSenderId: '559730617790',
    projectId: 'engro-1b941',
    authDomain: 'engro-1b941.firebaseapp.com',
    storageBucket: 'engro-1b941.appspot.com',
    measurementId: 'G-KM740X9TTH',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1Gz8zjKRK12kEKOyX_vr_312OhzyWCww',
    appId: '1:647061192002:android:697910b4663cec96d5dcdb',
    messagingSenderId: '647061192002',
    projectId: 'engro-buzz',
    storageBucket: 'engro-buzz.appspot.com',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCl68CSO819tI95zMyfX_yX7_HJBE33sNA',
    appId: '1:559730617790:ios:aec070c812572e79b6ddef',
    messagingSenderId: '559730617790',
    projectId: 'engro-1b941',
    storageBucket: 'engro-1b941.appspot.com',
    iosClientId:
        '559730617790-k5m9djme123mov7vskrde3fj9blgfkdm.apps.googleusercontent.com',
    iosBundleId: 'com.engro.xms',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCl68CSO819tI95zMyfX_yX7_HJBE33sNA',
    appId: '1:559730617790:ios:aec070c812572e79b6ddef',
    messagingSenderId: '559730617790',
    projectId: 'engro-1b941',
    storageBucket: 'engro-1b941.appspot.com',
    iosClientId:
        '559730617790-k5m9djme123mov7vskrde3fj9blgfkdm.apps.googleusercontent.com',
    iosBundleId: 'com.engro.xms',
  );
}
