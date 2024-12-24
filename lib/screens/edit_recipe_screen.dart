import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditRecipeScreen extends StatefulWidget {
  final String recipeId;
  final Map<String, dynamic> recipeData;

  const EditRecipeScreen({
    Key? key,
    required this.recipeId,
    required this.recipeData,
  }) : super(key: key);

  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;
  String? _imageUrl;
  bool _isUploading = false; // Untuk indikator loading saat unggah gambar

  final SupabaseClient _supabaseClient = Supabase.instance.client; // Inisialisasi Supabase Client

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipeData['title']);
    _ingredientsController =
        TextEditingController(text: (widget.recipeData['ingredients'] ?? []).join("\n"));
    _stepsController =
        TextEditingController(text: (widget.recipeData['steps'] ?? []).join("\n"));
    _imageUrl = widget.recipeData['image_url'];
  }

  Future<void> _pickAndUploadImage() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isUploading = true;
      });

      final File file = File(image.path);
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      // Upload image to Supabase Storage (make sure you're using the correct bucket)
      final storage = _supabaseClient.storage.from('recipes');
      final response = await storage.upload(fileName, file);

      if (response.error != null) {
        throw response.error!;
      }

      // Get the public URL for the uploaded image
      final String publicUrl = storage.getPublicUrl(fileName);

      if (publicUrl.isNotEmpty) {
        setState(() {
          _imageUrl = publicUrl; // Set the public URL of the uploaded image
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gambar berhasil diunggah")),
        );
      } else {
        throw Exception("Gagal mendapatkan URL gambar");
      }
    }
  } catch (e) {
    setState(() {
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal mengunggah gambar: $e")),
    );
  }
}



  Future<void> _updateRecipe() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('recipes').doc(widget.recipeId).update({
          'title': _titleController.text.trim(),
          'ingredients': _ingredientsController.text.trim().split("\n"),
          'steps': _stepsController.text.trim().split("\n"),
          'image_url': _imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resep berhasil diperbarui")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui resep: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Nama Resep",
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nama resep tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_imageUrl != null)
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(_imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    if (_isUploading)
                      const Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Ganti Gambar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Bahan-bahan (tekan Enter untuk menambah)",
                  style: TextStyle(color: Colors.black54),
                ),
                TextFormField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Bahan-bahan tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  "Langkah-langkah (tekan Enter untuk menambah)",
                  style: TextStyle(color: Colors.black54),
                ),
                TextFormField(
                  controller: _stepsController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Langkah-langkah tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _updateRecipe,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Tambah Resep",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on String {
  get error => null;
}