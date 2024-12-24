import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart';

class SavedRecipeScreen extends StatefulWidget {
  @override
  _SavedRecipeScreenState createState() => _SavedRecipeScreenState();
}

class _SavedRecipeScreenState extends State<SavedRecipeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> savedRecipes = [];

  @override
  void initState() {
    super.initState();
    _fetchSavedRecipes();
  }

  Future<void> _fetchSavedRecipes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userId = user.uid;

      final snapshot = await firestore
          .collection('saved_recipes')
          .where('user_id', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> recipesList = [];
      for (var doc in snapshot.docs) {
        final recipeId = doc['recipe_id'];

        final recipeSnapshot =
            await firestore.collection('recipes').doc(recipeId).get();

        if (recipeSnapshot.exists) {
          recipesList.add({
            ...recipeSnapshot.data() as Map<String, dynamic>,
            'id': recipeId,
            'doc_id': doc.id, // Tambahkan doc_id untuk penghapusan
          });
        }
      }

      setState(() {
        savedRecipes = recipesList;
      });
    } catch (error) {
      print("Error fetching saved recipes: $error");
    }
  }

  Future<void> _unsaveRecipe(String docId) async {
    try {
      await firestore.collection('saved_recipes').doc(docId).delete();
      setState(() {
        savedRecipes.removeWhere((recipe) => recipe['doc_id'] == docId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resep berhasil dihapus dari tersimpan.')),
      );
    } catch (error) {
      print("Error deleting saved recipe: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus resep.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resep Tersimpan'),
        backgroundColor: Color(0xFFFFBA07),
      ),
      body: savedRecipes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(recipe["title"] ?? "No Title"),
                    leading: recipe["image_url"] != null
                        ? Image.network(recipe["image_url"],
                            width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.image, size: 50),
                    trailing: IconButton(
                      icon: Icon(Icons.bookmark_remove, color: Colors.red),
                      onPressed: () {
                        _unsaveRecipe(recipe['doc_id']);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(
                            recipe: recipe, recipeId: 'recipe_id', recipes: '', savedRecipes: {},
                        ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

