import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'services/streak_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Update streak when app starts
  WidgetsFlutterBinding.ensureInitialized();
  await StreakService.updateStreak();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Pembelajaran Termodinamika',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Deep Indigo
          primary: const Color(0xFF1A237E), // Deep Indigo
          secondary: const Color(0xFFFF6D00), // Energetic Orange
        ),
        useMaterial3: true,
        fontFamily: 'StackSansText',
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // User is logged in, check if user document exists in Firestore
          return FutureBuilder(
            future: _checkUserDataExists(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (userSnapshot.hasData) {
                // User document exists, check the role
                String role = userSnapshot.data!['role'] ?? 'siswa';
                if (role == 'admin') {
                  return const AdminScreen();
                } else {
                  return const HomeScreen();
                }
              } else {
                // User document doesn't exist yet, show loading or redirect to login
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
        } else {
          // User is not logged in
          return const LoginScreen();
        }
      },
    );
  }

  // Helper function to check if user document exists in Firestore
  static Future<Map<String, dynamic>?> _checkUserDataExists(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
          
      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        return userData;
      }
      return null;
    } catch (e) {
      print('Error checking user data: $e');
      return null;
    }
  }
}
