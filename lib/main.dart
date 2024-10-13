import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // นำเข้า firebase_options.dart ที่สร้างด้วย FlutterFire CLI
import 'login.dart'; // นำเข้า LoginPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // รันแอปโดยใช้ FutureBuilder เพื่อเช็คการเชื่อมต่อ Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Course Selling',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirebaseInitScreen(), // ใช้หน้าจอ FirebaseInitScreen
    );
  }
}

// สร้าง StatefulWidget เพื่อแสดงสถานะการเชื่อมต่อ Firebase
class FirebaseInitScreen extends StatefulWidget {
  const FirebaseInitScreen({super.key});

  @override
  _FirebaseInitScreenState createState() => _FirebaseInitScreenState();
}

class _FirebaseInitScreenState extends State<FirebaseInitScreen> {
  // สถานะการเชื่อมต่อ
  late Future<FirebaseApp> _initialization;

  @override
  void initState() {
    super.initState();
    // เริ่มการเชื่อมต่อกับ Firebase
    _initialization = _initializeFirebase();
  }

  // ฟังก์ชันเริ่มต้นการเชื่อมต่อกับ Firebase
  Future<FirebaseApp> _initializeFirebase() async {
    try {
      // เรียกใช้ Firebase.initializeApp() โดยใช้ DefaultFirebaseOptions
      return await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print('Error connecting to Firebase: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // เช็คสถานะการเชื่อมต่อ
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // แสดง Loading Spinner ขณะรอ
            ),
          );
        } else if (snapshot.hasError) {
          // หากมีข้อผิดพลาดในการเชื่อมต่อ
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error connecting to Firebase. Please try again.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // กดเพื่อรีโหลดหน้าจอและลองเชื่อมต่อใหม่
                      setState(() {
                        _initialization = _initializeFirebase();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else {
          // หากเชื่อมต่อสำเร็จ แสดงหน้าจอหลัก
          return const LoginPage();
        }
      },
    );
  }
}
