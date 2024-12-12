// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'home_screen.dart';
import 'voice_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase tùy thuộc vào môi trường (Web hoặc Mobile)
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAAgJxwkOvlu2zR7AluMjxKxRrhjqokW1E",
        authDomain: "energy-system-esp32.firebaseapp.com",
        databaseURL:
            "https://energy-system-esp32-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "energy-system-esp32",
        storageBucket: "energy-system-esp32.appspot.com",
        messagingSenderId: "818419284691",
        appId: "1:818419284691:web:0e684af580bf3e914a3226",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Energy Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/auth', // Mặc định chuyển đến màn hình đăng nhập
      routes: {
        '/auth': (context) => const AuthScreen(), // Route đến màn hình đăng nhập
        '/home': (context) => const HomeScreen(), // Route đến màn hình chính
        '/voice': (context) => const VoiceScreen(), // Route đến màn hình Voice
      },
    );
  }
}
