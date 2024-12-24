import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class AboutUsScreen extends StatelessWidget {
  // Method to open Instagram
  Future<void> _openInstagram() async {
    const url = 'https://www.instagram.com/wdiathrsiaa_?igsh=cHk0ZThnZHkzaGNh'; // Replace with your Instagram username
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open the URL $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tentang Kami',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFFFBA07),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ilustrasi atau gambar
              Center(
                child: Image.asset(
                  'aboutus.jpg', // Sesuaikan dengan path ilustrasi Anda
                  height: 300,
                  width: 300,
                ),
              ),
              SizedBox(height: 0),

              // Nama aplikasi dan versi
              Text(
                'COOKITA',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 0),
              Text(
                'Version 0.1',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 6),

              // Deskripsi aplikasi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  'Cookita adalah platform resep yang memudahkan anda menemukan, berbagi, dan menyimpan hidangan favorit. Kami percaya bahwa setiap hidangan memiliki cerita, dan disini kami ingin mendukung anda dalam menjelajahi beragam resep, mulai dari hidangan sehari-hari hingga kreasi spesial. Yuk, temukan inspirasi memasak dan jadikan moment di dapur bermakna bersama Cookita!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center, // Letakkan TextAlign di sini
                ),
              ),
              SizedBox(height: 10),

              // Tautan ke media sosial (Instagram)
              GestureDetector(
                onTap: _openInstagram,  // Use the method to open Instagram
                child: Text(
                  'Kepoin media sosial kami disini!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Ikon Instagram (using image instead of icon)
              GestureDetector(
                onTap: _openInstagram,  // Use the method to open Instagram
                child: Image.asset(
                  'ig.jpg', // Use your Instagram image asset
                  height: 40,
                  width: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}