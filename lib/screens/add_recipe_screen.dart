import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddRecipeScreen extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? recipe;

  AddRecipeScreen({this.isEdit = false, this.recipe});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  String? _imageUrl;
  Uint8List? _imageBytes;
  bool _isUploading = false;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.recipe != null) {
      _titleController.text = widget.recipe!["title"];
      _ingredientsController.text = widget.recipe!["ingredients"].join('\n');
      _stepsController.text = widget.recipe!["steps"].join('\n');
      _imageUrl = widget.recipe!["image_url"];
    }
  }

  Future<void> _pickImage() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    await input.onChange.first;
    if (input.files?.isNotEmpty ?? false) {
      final html.File file = input.files![0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      setState(() {
        _imageBytes = reader.result as Uint8List;
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (_titleController.text.trim().isEmpty ||
        _ingredientsController.text.trim().isEmpty ||
        _stepsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua kolom harus diisi")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl = _imageUrl;

      // Upload image to Supabase
      if (_imageBytes != null) {
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final uploadResponse = await _supabase.storage.from('recipes').uploadBinary(fileName, _imageBytes!);

        if (uploadResponse.error == null) {
          // Get the public URL of the image
          imageUrl = _supabase.storage.from('recipes').getPublicUrl(fileName);
        }
      }

      // Ambil user ID dari FirebaseAuth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pengguna tidak ditemukan. Silakan login ulang.")),
        );
        return;
      }

      // Prepare data for Firestore
      final data = {
        "title": _titleController.text.trim(),
        "ingredients": _ingredientsController.text.trim().split('\n').map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '')).toList(),
        "steps": _stepsController.text.trim().split('\n').map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '')).toList(),
        "image_url": imageUrl,
        "id_user": user.uid, // Tambahkan user ID
        "created_at": DateTime.now().toIso8601String(),
      };

      // Save data to Firebase Firestore
      if (widget.isEdit) {
        await FirebaseFirestore.instance
            .collection('recipes')
            .doc(widget.recipe!["id"])
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('recipes').add(data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEdit ? "Resep diperbarui" : "Resep ditambahkan")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan resep: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _handleInputChange(String value, TextEditingController controller) {
    final lines = value.split('\n');
    final updatedLines = <String>[];

    for (int i = 0; i < lines.length; i++) {
      updatedLines.add('${i + 1}. ${lines[i].replaceFirst(RegExp(r'^\d+\.\s*'), '')}');
    }

    controller.value = TextEditingValue(
      text: updatedLines.join('\n'),
      selection: TextSelection.collapsed(offset: updatedLines.join('\n').length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? "Edit Resep" : "Tambah Resep"),
        backgroundColor: Color(0xFFFFBA07),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: "Nama Resep"),
          ),
          SizedBox(height: 16),
          _imageBytes == null && _imageUrl == null
              ? TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.add_a_photo),
                  label: Text("Pilih Gambar"),
                )
              : (_imageBytes != null
                  ? Image.memory(_imageBytes!)
                  : Image.network(_imageUrl!)),
          SizedBox(height: 16),
          TextField(
            controller: _ingredientsController,
            maxLines: 5,
            decoration: InputDecoration(labelText: "Bahan-bahan (tekan Enter untuk menambah)"),
            onChanged: (value) {
              _handleInputChange(value, _ingredientsController);
            },
          ),
          SizedBox(height: 16),
          TextField(
            controller: _stepsController,
            maxLines: 7,
            decoration: InputDecoration(labelText: "Langkah-langkah (tekan Enter untuk menambah)"),
            onChanged: (value) {
              _handleInputChange(value, _stepsController);
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isUploading ? null : _saveRecipe,
            child: _isUploading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(widget.isEdit ? "Simpan Perubahan" : "Tambah Resep"),
          ),
        ],
      ),
    );
  }
}

extension on String {
  get error => null;
}
