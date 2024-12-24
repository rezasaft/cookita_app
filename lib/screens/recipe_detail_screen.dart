import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final String recipeId;

  RecipeDetailScreen({
    required this.recipe,
    required this.recipeId, required String recipes, required Map savedRecipes,
  });

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isSaved = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfRecipeIsSaved();
  }

  /// Mengecek apakah resep sudah disimpan di database
  Future<void> _checkIfRecipeIsSaved() async {
    setState(() {
      isLoading = true; // Tampilkan loading saat inisialisasi
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final recipeId = widget.recipeId;

      if (userId != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('saved_recipes')
            .where('user_id', isEqualTo: userId)
            .where('recipe_id', isEqualTo: recipeId)
            .get();

        setState(() {
          isSaved = docSnapshot.docs.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint("Error checking if recipe is saved: $e");
    } finally {
      setState(() {
        isLoading = false; // Sembunyikan loading setelah inisialisasi
      });
    }
  }

  /// Menyimpan atau menghapus status bookmark di Firestore
  Future<void> _saveOrUnsaveRecipe(String recipeId, bool isSaved) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;

    try {
      if (isSaved) {
        // Simpan resep ke Firestore jika belum ada
        await FirebaseFirestore.instance.collection('saved_recipes').add({
          'user_id': userId,
          'recipe_id': recipeId,
          'saved_at': FieldValue.serverTimestamp(),
        });
      } else {
        // Hapus resep dari Firestore
        final querySnapshot = await FirebaseFirestore.instance
            .collection('saved_recipes')
            .where('user_id', isEqualTo: userId)
            .where('recipe_id', isEqualTo: recipeId)
            .get();

        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (error) {
      print("Error updating bookmark status: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gambar Background
          widget.recipe["image_url"] != null
              ? Image.network(
                  widget.recipe["image_url"],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Placeholder(
                        fallbackHeight: 300, fallbackWidth: double.infinity);
                  },
                )
              : const Placeholder(
                  fallbackHeight: 300, fallbackWidth: double.infinity),

          // Konten Resep
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe["title"] ?? "Judul Tidak Tersedia",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Bahan-bahan:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      for (var ingredient in widget.recipe["ingredients"] ?? [])
                        Text("• $ingredient"),
                      const SizedBox(height: 16),
                      const Text(
                        "Langkah-langkah:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      for (var step in widget.recipe["steps"] ?? [])
                        Text(
                            "${widget.recipe["steps"].indexOf(step) + 1}. $step"),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tombol Kembali
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orange),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Tombol Bookmark
          Positioned(
            top: 40,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.orange,
                    )
                  : IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.orange,
                      ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true; // Tampilkan loading
                        });

                        try {
                          final recipeId = widget.recipeId;
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;

                          // Ambil status bookmark dari Firestore
                          final querySnapshot = await FirebaseFirestore.instance
                              .collection('saved_recipes')
                              .where('user_id', isEqualTo: user.uid)
                              .where('recipe_id', isEqualTo: recipeId)
                              .get();

                          final isCurrentlySaved =
                              querySnapshot.docs.isNotEmpty;

                          // Update status bookmark di Firestore
                          await _saveOrUnsaveRecipe(
                              recipeId, !isCurrentlySaved);

                          // Perbarui state lokal
                          setState(() {
                            isSaved = !isCurrentlySaved;
                          });
                        } catch (error) {
                          debugPrint("Error updating bookmark: $error");
                        } finally {
                          setState(() {
                            isLoading = false; // Sembunyikan loading
                          });
                        }
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}