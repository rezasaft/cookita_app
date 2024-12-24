import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _profileImagePath = 'assets/default_avatar.png'; // Path gambar lokal

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _usernameController.text = user.displayName ?? '';
    }
  }

  Future<void> _saveChanges() async {
    final user = _auth.currentUser;

    if (user != null) {
      await user.updateDisplayName(_usernameController.text);

      if (_passwordController.text.isNotEmpty) {
        await user.updatePassword(_passwordController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Perubahan profil berhasil disimpan!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan Profil"),
        backgroundColor: Color(0xFFFFBA07),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Gambar Profil (dari aset lokal)
              ClipOval(
                child: Image.asset(
                  _profileImagePath,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),

              // Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Email (Hanya Baca)
              TextField(
                controller: _emailController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Baru (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),

              // Tombol Simpan Perubahan
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text(
                  "Simpan Perubahan",
                  style: TextStyle(color: Colors.black), // Warna teks hitam
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





//tampilan ini sudah bisa jalan, namun tidak bisa menmabhkan foto profile 

// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ProfileScreen extends StatefulWidget {
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final SupabaseClient _supabase = Supabase.instance.client;

//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   XFile? _imageFile; // File gambar yang dipilih
//   String? _profileImageUrl; // URL gambar profil

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   // Fungsi untuk memuat data pengguna dari Firebase dan Supabase
//   Future<void> _loadUserData() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       _emailController.text = user.email ?? '';
//       _usernameController.text = user.displayName ?? '';

//       // Ambil URL gambar profil dari Supabase
//       final response = await _supabase
//           .from('profiles')
//           .select('avatar_url')
//           .eq('id', user.uid)
//           .single();
//       if (response.data != null && response.data['avatar_url'] != null) {
//         setState(() {
//           _profileImageUrl = response.data['avatar_url'];
//         });
//       }
//     }
//   }

//   // Fungsi untuk memilih gambar
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = pickedFile;
//       });
//     }
//   }

//   // Fungsi untuk mengunggah gambar ke Supabase
//   Future<void> _uploadImage() async {
//     if (_imageFile == null) return;

//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       // Konversi file menjadi byte array
//       final bytes = await _imageFile!.readAsBytes();

//       // Nama file unik berdasarkan UID pengguna dan waktu
//       final fileName = '${user.uid}-${DateTime.now().millisecondsSinceEpoch}.png';

//       // Unggah file ke Supabase
//       final response = await _supabase.storage.from('avatars').uploadBinary(
//         fileName,
//         bytes,
//         fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
//       );

//       if (response.isEmpty) {
//         throw Exception("Upload gagal");
//       }

//       // Dapatkan URL publik gambar
//       final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

//       // Perbarui URL gambar di database
//       final updateResponse = await _supabase.from('profiles').upsert({
//         'id': user.uid,
//         'avatar_url': imageUrl,
//       });

//       if (updateResponse.error != null) {
//         throw Exception("Database update gagal: ${updateResponse.error!.message}");
//       }

//       setState(() {
//         _profileImageUrl = imageUrl;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Gambar profil berhasil diperbarui!")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Terjadi kesalahan: $e")),
//       );
//     }
//   }

//   // Fungsi untuk menyimpan perubahan
//   Future<void> _saveChanges() async {
//     final user = _auth.currentUser;

//     if (user != null) {
//       await user.updateDisplayName(_usernameController.text);

//       if (_passwordController.text.isNotEmpty) {
//         await user.updatePassword(_passwordController.text);
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Perubahan profil berhasil disimpan!")),
//       );

//       // Jika ada gambar baru, unggah ke Supabase
//       if (_imageFile != null) {
//         await _uploadImage();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Pengaturan Profil"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // Gambar Profil dengan GestureDetector
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: _imageFile == null && _profileImageUrl == null
//                     ? Container(
//                         height: 200,
//                         width: 200,  // Mengatur ukuran agar berbentuk lingkaran
//                         decoration: BoxDecoration(
//                           color: Colors.grey[200],
//                           shape: BoxShape.circle,  // Membuat gambar menjadi lingkaran
//                         ),
//                         child: Center(
//                           child: Icon(
//                             Icons.add_a_photo,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       )
//                     : _imageFile != null
//                         ? ClipOval(
//                             child: kIsWeb
//                                 ? Image.network(
//                                     _imageFile!.path,
//                                     height: 200,
//                                     width: 200,  // Mengatur ukuran agar berbentuk lingkaran
//                                     fit: BoxFit.cover,
//                                   )
//                                 : Image.file(
//                                     File(_imageFile!.path),
//                                     height: 200,
//                                     width: 200,  // Mengatur ukuran agar berbentuk lingkaran
//                                     fit: BoxFit.cover,
//                                   ),
//                           )
//                         : ClipOval(
//                             child: Image.network(
//                               _profileImageUrl!,
//                               height: 200,
//                               width: 200,  // Mengatur ukuran agar berbentuk lingkaran
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//               ),
//               SizedBox(height: 16),

//               // Username
//               TextField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   labelText: 'Username',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 16),

//               // Email
//               TextField(
//                 controller: _emailController,
//                 enabled: false,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 16),

//               // Password
//               TextField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password Baru (Opsional)',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 32),

//               // Tombol Simpan Perubahan
//               ElevatedButton(
//                 onPressed: _saveChanges,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//                 child: Text("Simpan Perubahan"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }