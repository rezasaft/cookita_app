import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Tambahkan alias
import 'firebase_options.dart'; // Pastikan ini sudah benar
import 'Profile/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Global helper untuk Supabase client
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase before calling any Supabase instance
  await Supabase.initialize(
    url: 'https://akwufjdesmtlrpnzbxrm.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrd3VmamRlc210bHJwbnpieHJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI3NTgyMTYsImV4cCI6MjA0ODMzNDIxNn0.JFFXcqnHSBjxoy5Yy4nC2COGme62pMvf1iVoaTCmmLo', // Replace with your Supabase anon key
  );

  runApp(CookitaApp());
}

class CookitaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(), // Gunakan alias
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); 
        } else if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return HomeScreen(); 
        } else {
          return LoginScreen(); 
        }
      },
    );
  }
}