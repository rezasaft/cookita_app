import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String name;
  final String image;
  final String recipeId;
  final bool isSaved;
  final ValueChanged<bool> onSaveChanged;

  RecipeCard({
    required this.name,
    required this.image,
    required this.recipeId,
    required this.isSaved,
    required this.onSaveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image, 
                                size: 30,
                                color: Colors.grey[600]),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}