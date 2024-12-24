import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';
import 'saved_recipe_screen.dart';
import '../Profile/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0;
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  Map<String, bool> savedRecipes = {}; // menyimpan status bookmark untuk resep

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _fetchSavedRecipes();
  }

  // Future<void> _fetchRecipes() async {
  //   try {
  //     final snapshot = await firestore.collection('recipes').get();
  //     setState(() {
  //       recipes = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  //       filteredRecipes = recipes;
  //     });
  //   } catch (error) {
  //     print("Error fetching recipes: $error");
  //   }
  // }

  Future<void> _fetchRecipes() async {
    try {
      final snapshot = await firestore.collection('recipes').get();
      setState(() {
        recipes = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Add document ID to the data
          return data;
        }).toList();
        filteredRecipes = recipes;
      });
    } catch (error) {
      print("Error fetching recipes: $error");
    }
  }

  Future<void> _fetchSavedRecipes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userId = user.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('saved_recipes')
          .where('user_id', isEqualTo: userId)
          .get();

      setState(() {
        savedRecipes = Map.fromEntries(
          snapshot.docs.map((doc) => MapEntry(doc['recipe_id'].toString(), true)),
        );
      });
    } catch (error) {
      print("Error fetching saved recipes: $error");
    }
  }

  void _filterRecipes(String query) {
    setState(() {
      filteredRecipes = recipes.where((recipe) {
        return recipe["title"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddRecipeScreen()),
      ).then((newRecipe) {
        if (newRecipe != null) {
          setState(() {
            recipes.add(newRecipe);
            filteredRecipes = recipes;
          });
        }
      });
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SavedRecipeScreen()),
      );
    }
  }
  

  Future<void> _saveOrUnsaveRecipe(String recipeId, bool isSaved) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userId = user.uid;

  try {
    if (isSaved) {
      // Simpan resep
      await FirebaseFirestore.instance.collection('saved_recipes').add({
        'user_id': userId,
        'recipe_id': recipeId,
        'saved_at': FieldValue.serverTimestamp(),
      });
    } else {
      // Hapus dari koleksi saved_recipes
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
      body: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    'assets/background.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Text(
                                'COOKITA',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'TEMUKAN RESEP MASAKANMU!',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.0),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.person,
                                color: Colors.black,
                                size: 50),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingsScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: _filterRecipes,
              decoration: InputDecoration(
                hintText: 'Cari resep...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.75,
                ),
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
  final recipe = filteredRecipes[index];
  final recipeId = recipe["id"].toString(); // Ambil ID resep

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailScreen(
            recipe: recipe,
            recipeId: recipeId, recipes: '', savedRecipes: {},
          ),
        ),
      );
    },
    child: RecipeCard(
      name: recipe["title"],
      image: recipe["image_url"],
      recipeId: recipeId,
      isSaved: savedRecipes[recipeId] ?? false, // Cek status bookmark
      onSaveChanged: (bool isSaved) async {
        // Update state dan database
        setState(() {
          savedRecipes[recipeId] = isSaved;
        });
        await _saveOrUnsaveRecipe(recipeId, isSaved);
      },
    ),
  );
}


              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Tambah Resep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Tersimpan',
          ),
        ],
      ),
    );
  }
}