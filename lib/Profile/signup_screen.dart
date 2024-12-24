import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart'; // Ganti dengan nama file HomeScreen Anda
import '../Profile/login_screen.dart'; // Pastikan Anda sudah memiliki halaman login_screen.dart

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();

      try {
        // Buat akun dengan Firebase
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Update nama pengguna
        await userCredential.user!.updateDisplayName(username);

        // Ambil UID pengguna
        String uid = userCredential.user!.uid;

        // Simpan data pengguna ke Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          'username': username,
          'uid': uid,
          'createdAt': FieldValue.serverTimestamp(), // Waktu pendaftaran
        });

        // Simpan status login
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // Arahkan ke halaman Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Ubah di sini
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        String message = e.message ?? "Terjadi kesalahan saat mendaftar.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 166, 5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Daftar",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Input Email
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Alamat E-mail',
                      hintText: 'masukkan alamat e-mail',
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong.';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Masukkan email yang valid.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Input Password
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'masukkan password',
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong.';
                      }
                      if (value.length < 6) {
                        return 'Password harus memiliki minimal 6 karakter.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Input Konfirmasi Password
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      hintText: 'konfirmasi password',
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password tidak boleh kosong.';
                      }
                      if (value != passwordController.text) {
                        return 'Konfirmasi password tidak sesuai.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Input Username
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'masukkan username',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username tidak boleh kosong.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),

                  // Tombol Daftar
                  ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 248, 172, 6),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    child: const Text(
                          "Daftar",
                          style: TextStyle(
                            color: Colors.black, 
                          ),
                  ),
                  ),
                  // Tautan untuk login (sejajar)
                  SizedBox(height: 20),
                  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah memiliki akun?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(color: Color(0xFFFFBA07)),
                    ),
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
