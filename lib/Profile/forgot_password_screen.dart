import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String message = '';

  Future<void> resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      setState(() {
        message = 'Tautan pemulihan kata sandi telah dikirim ke email Anda.';
      });
    } catch (e) {
      setState(() {
        message = 'Gagal mengirim email: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Lupa Password', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFFFFBA07),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Icon(Icons.lock_reset, size: 80, color: Colors.black),
              SizedBox(height: 20),
              Text(
                'Pulihkan Password',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: Icon(Icons.email),
                  hintText: 'Masukkan e-mail Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (message.isNotEmpty)
                Text(
                  message,
                  style: TextStyle(
                    color: message.startsWith('Tautan')
                        ? Colors.green
                        : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFBA07),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Kirim Email Pemulihan',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Kembali ke halaman login
                },
                child: Text('Kembali ke Login',
                    style: TextStyle(color: Color(0xFFFFBA07))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}