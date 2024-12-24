import 'package:cookita_app/screens/edit_recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_detail_screen.dart'; // Pastikan file ini ada dan diimpor dengan benar

class ResepAndaScreen extends StatefulWidget {
  @override
  _ResepAndaScreenState createState() => _ResepAndaScreenState();
}

class _ResepAndaScreenState extends State<ResepAndaScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getUserRecipesStream() {
    if (_currentUser == null) {
      // Return an empty stream if the user is not logged in
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('recipes')
        .where('id_user', isEqualTo: _currentUser!.uid)
        .snapshots();
  }

  Future<void> _deleteRecipe(String recipeId) async {
    try {
      await FirebaseFirestore.instance.collection('recipes').doc(recipeId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Resep berhasil dihapus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus resep: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resep Anda"),
        backgroundColor: const Color(0xFFFFBA07),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _getUserRecipesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Anda belum menambahkan resep."));
          }

          final recipes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final recipeData = recipe.data();
              final recipeId = recipe.id;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: recipeData['image_url'] != null
                      ? Image.network(
                          recipeData['image_url'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.fastfood, size: 50),
                  title: Text(recipeData['title'] ?? 'Tanpa Judul'),
                  subtitle: Text(
                    "Ditambahkan pada: ${recipeData['created_at'] ?? 'Tidak diketahui'}",
                  ),
                  trailing: PopupMenuButton<String>(
  onSelected: (value) {
    if (value == 'Edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditRecipeScreen(
            recipeId: recipeId,
            recipeData: recipeData, 
          ),
        ),
      );
    } else if (value == 'Hapus') {
      _deleteRecipe(recipeId);
    }
  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'Edit',
      child: Text("Edit Resep"),
    ),
    const PopupMenuItem(
      value: 'Hapus',
      child: Text("Hapus Resep"),
    ),
  ],
),


                  onTap: () {
  final recipeData = recipe.data();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RecipeDetailScreen(
        recipe: recipeData, // Data resep
        recipeId: recipe.id, // ID resep
        recipes: recipes.toString(), // Daftar resep (opsional, konfirmasikan konteksnya)
        savedRecipes: {}, // Map kosong (sesuaikan sesuai kebutuhan Anda)
      ),
    ),
  );
},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
