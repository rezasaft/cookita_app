import 'package:cookita_app/screens/resep_anda_screen.dart';
import 'package:cookita_app/screens/saved_recipe_screen.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'about_us_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  // Fungsi untuk logout
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Arahkan pengguna ke halaman login setelah logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Ganti LoginScreen() dengan halaman login kamu
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
        backgroundColor: Color(0xFFFFBA07),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Tombol Akun
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.grey),
            title: Text('Akun', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          Divider(),

          // Tombol Tersimpan
          ListTile(
            leading: Icon(Icons.restaurant_menu, color: Colors.grey),
            title: Text('Resep Anda', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ResepAndaScreen()));
            },
          ),
          Divider(),

          // Tombol Tentang Kami
          ListTile(
            leading: Icon(Icons.info, color: Colors.grey),
            title: Text('Tentang Kami', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsScreen()),
              );
            },
          ),
          Divider(),

          // Tombol Logout
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Keluar', style: TextStyle(fontSize: 18, color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
