// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rongo/model/recipe.dart';
import 'package:rongo/model/recipe_meal_type.dart';
import 'package:rongo/screen/chatbot/chat.dart';
import 'package:rongo/screen/recipe/recipe_details_page.dart';
import 'package:rongo/utils/theme/theme.dart';

class RecipeHomePage extends StatefulWidget {
  final Object? currentUser;
  const RecipeHomePage({super.key, this.currentUser});

  @override
  State<RecipeHomePage> createState() => _RecipeHomePageState();
}

class _RecipeHomePageState extends State<RecipeHomePage> {
  get currentUser => widget.currentUser;
  final List<Map<String, dynamic>> _inventory = [];
  final List<Recipe> _recipes = [
    Recipe(
      name: 'Spaghetti Aglio e Olio',
      description: 'A simple pasta dish with garlic and olive oil',
      imageUrl:
          'https://theplantbasedschool.com/wp-content/uploads/2022/04/Aglio-olio-1-1.jpg',
      ingredients: [
        'Spaghetti',
        'Garlic',
        'Olive oil',
        'Red pepper flakes',
        'Parsley',
        'Parmesan cheese',
      ],
      steps: [
        'Boil spaghetti in salted water until al dente',
        'In a pan, heat olive oil and garlic until fragrant',
        'Add red pepper flakes and parsley',
        'Add cooked spaghetti and toss until coated',
        'Serve with grated Parmesan cheese',
      ],
      nutritionalValue: [
        'Calories: 500',
        'Fat: 20g',
        'Carbs: 70g',
        'Protein: 15g',
      ],
      cookingTime: "30 minutes",
      tags: [
        'Italian',
        'Pasta',
        'Vegetarian',
      ],
    ),
    Recipe(
      name: 'Chicken Alfredo',
      description: 'A creamy pasta dish with chicken and Alfredo sauce',
      imageUrl:
          'https://assets.epicurious.com/photos/5988e3458e3ab375fe3c0caf/4:3/w_4808,h_3606,c_limit/How-to-Make-Chicken-Alfredo-Pasta-hero-02082017.jpg',
      ingredients: [
        'Fettuccine',
        'Chicken breast',
        'Butter',
        'Heavy cream',
        'Garlic',
        'Parmesan cheese',
      ],
      steps: [
        'Cook fettuccine in salted water until al dente',
        'Season chicken breast with salt and pepper',
        'In a pan, cook chicken until browned and cooked through',
        'In the same pan, melt butter and sauté garlic',
        'Add heavy cream and Parmesan cheese',
        'Add cooked fettuccine and chicken',
        'Serve with more Parmesan cheese',
      ],
      nutritionalValue: [
        'Calories: 700',
        'Fat: 30g',
        'Carbs: 60g',
        'Protein: 40g',
      ],
      cookingTime: "45 minutes",
      tags: [
        'Italian',
        'Pasta',
        'Chicken',
      ],
    ),
  ];

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
                  child: Expanded(
                    child: ListView.builder(
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final Recipe recipe = _recipes[index];
                        return ListTile(
                          title: Container(
                            decoration: BoxDecoration(
                                color: AppTheme.backgroundWhite,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.30),
                                    spreadRadius: 2,
                                    blurRadius: 3,
                                    offset: const Offset(0, 3),
                                  ),
                                ]),
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Image.network(recipe.imageUrl),
                                const SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    recipe.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(recipe.description)),
                                const SizedBox(height: 5),
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
          ),
          // dropdown overlay
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: height * 0.15),
              width: width * 0.9,
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
                  setState(() {});
                },
              ),
            ),
          ),
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
