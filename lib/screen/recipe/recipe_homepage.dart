// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:rongo/model/recipe.dart';
import 'package:rongo/model/recipe_meal_type.dart';
import 'package:rongo/screen/chatbot/chat.dart';
import 'package:rongo/screen/recipe/recipe_details_page.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/utils/utils.dart';

class RecipeHomePage extends StatefulWidget {
  final Object? currentUser;
  const RecipeHomePage({super.key, this.currentUser});

  @override
  State<RecipeHomePage> createState() => _RecipeHomePageState();
}

class _RecipeHomePageState extends State<RecipeHomePage> {
  get currentUser => widget.currentUser;
  final List<Map<String, dynamic>> _inventory = [];
  //bool _isLoading = false;
  final List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    pullContextFromFirebase();
  }

  Future<void> pullContextFromFirebase() async {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection('fridges').doc(currentUser["fridgeId"]);
    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final inventory = docSnapshot.data()!['inventory'] as List<dynamic>;
        final filteredInventory = inventory
            .map((item) => {
                  'name': item['name'],
                  'currentQuantity': item['currentQuantity'],
                  'expiryDate': item['expiryDate'],
                })
            .toList();
        for (final item in filteredInventory) {
          _inventory.add(item);
        }
      } else {
        print("document does not exist");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _navigateToRecipeDetails(int index) {
    final Recipe recipe = _recipes[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsPage(recipe: recipe),
      ),
    );
  }

  Future<void> generateRecipe(MealType mealType) async {
    // Clear the existing recipes
    setState(() {
      _recipes.clear();
    });

    String category = mealType.name;
    String unsplashKey = dotenv.env['UNSPLASH_ACCESS_KEY']!;
    var prompt =
        "The user $currentUser is requesting for a $category recipe based on their inventory which includes $_inventory."
        "Please suggest an appropriate recipe and return it in a JSON format."
        "The JSON for recipe must strictly follow this data schema: {name: string, description: string, cookingTime: string, tags: List<String>}"
        "Make sure to add the origin of food in the tags."
        "Do not reply any additional information other than the recipe JSON."
        "Do not include the formatting in the JSON response.";
    final content = [Content.text(prompt)];

    try {
      final response = await model.generateContent(content);
      if (response.text == null || response.text!.isEmpty) {
        throw FormatException('Empty response from the model');
      }

      final map = jsonDecode(response.text!) as Map<String, dynamic>;

      String foodName = map['name'];
      final imageUrl = await http.get(Uri.parse(
          'https://api.unsplash.com/search/photos/?client_id=$unsplashKey&query=$foodName'));

      if (imageUrl.statusCode == 200) {
        final imageMap = jsonDecode(imageUrl.body) as Map<String, dynamic>;
        final image = imageMap['results'][0]['urls']['regular'];
        map['imageUrl'] = image;
      } else {
        print('Unsplash API error: ${imageUrl.statusCode}');
      }

      final recipe = Recipe(
        name: map['name'],
        imageUrl: map['imageUrl'],
        description: map['description'],
        cookingTime: map['cookingTime'],
        tags: List<String>.from(map['tags']),
      );

      // Add the new recipe to the list
      setState(() {
        _recipes.add(recipe);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;

    return Scaffold(
      body: Stack(
        children: [
          // background image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'lib/images/recipeHomePage.png',
              fit: BoxFit.cover,
            ),
          ),
          // recipe overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                height: height * 0.70,
                width: width,
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 50.0),
                  child: ListView.builder(
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final Recipe recipe = _recipes[index];
                      return ListTile(
                        title: Container(
                          decoration: BoxDecoration(
                              color: AppTheme.backgroundWhite,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.30),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: const Offset(0, 3),
                                ),
                              ]),
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Image.network(recipe.imageUrl),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  recipe.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(recipe.description,
                                      style: AppTheme.blackBodyText)),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: recipe.tags
                                      .map((tag) => _buildTag(tag))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Cooking time: ${recipe.cookingTime}",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () => _navigateToRecipeDetails(index),
                                child: Container(
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.all(10),
                                  alignment: Alignment.center,
                                  width: width * 0.4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    color: AppTheme.mainGreen,
                                  ),
                                  child: const Text(
                                    "Get Started",
                                    style: TextStyle(
                                        color: AppTheme.backgroundWhite),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // dropdown overlay
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: height * 0.15),
              width: width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonFormField<MealType>(
                hint: const Text("What meal are you cooking?"),
                iconSize: 0,
                decoration: AppTheme.recipeDropdownMenu,
                items: MealType.values.map((MealType type) {
                  return DropdownMenuItem<MealType>(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (MealType? newValue) {
                  generateRecipe(newValue!);
                },
              ),
            ),
          )
        ],
      ),
      // trigger chatbot
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 10, 70),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(currentUser: currentUser))),
          backgroundColor: AppTheme.backgroundWhite,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              'lib/images/rongie.png',
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildTag(String tag) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.mainGreen,
      borderRadius: BorderRadius.circular(32.0),
    ),
    child: Text(
      tag,
      style: const TextStyle(
        fontSize: 12.0, // Adjust font size as needed
        color: Colors.white,
      ),
    ),
  );
}
