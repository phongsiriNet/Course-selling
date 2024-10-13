import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] สำหรับการใช้กับแอป Firebase ของคุณ
///
/// ตัวอย่าง:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions ยังไม่ได้ตั้งค่าสำหรับ iOS - '
          'คุณสามารถตั้งค่าใหม่ได้โดยรัน FlutterFire CLI อีกครั้ง.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions ยังไม่ได้ตั้งค่าสำหรับ macOS - '
          'คุณสามารถตั้งค่าใหม่ได้โดยรัน FlutterFire CLI อีกครั้ง.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions ยังไม่ได้ตั้งค่าสำหรับ Linux - '
          'คุณสามารถตั้งค่าใหม่ได้โดยรัน FlutterFire CLI อีกครั้ง.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions ไม่รองรับสำหรับแพลตฟอร์มนี้.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCW4wFZLTgpEsJxgb2EwQD-vzKlqTJjAJs',
    appId: '1:700357667967:web:9d28fb79eea9920d72234a',
    messagingSenderId: '700357667967',
    projectId: 'test2-545a7',
    authDomain: 'test2-545a7.firebaseapp.com',
    storageBucket: 'test2-545a7.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbJWDJ0D6KN_yk621GvufHKpB1F_82xhc',
    appId: '1:700357667967:android:dedadf7de6a2b6d972234a',
    messagingSenderId: '700357667967',
    projectId: 'test2-545a7',
    storageBucket: 'test2-545a7.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCW4wFZLTgpEsJxgb2EwQD-vzKlqTJjAJs',
    appId: '1:700357667967:web:4a0010ac8563118472234a',
    messagingSenderId: '700357667967',
    projectId: 'test2-545a7',
    authDomain: 'test2-545a7.firebaseapp.com',
    storageBucket: 'test2-545a7.appspot.com',
  );

}