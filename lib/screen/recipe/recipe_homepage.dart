// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:rongo/model/recipe.dart';
import 'package:rongo/model/recipe_meal_type.dart';
import 'package:rongo/provider/meal_type_provider.dart';
import 'package:rongo/provider/recipe_provider.dart';
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
  bool _isLoading = false;

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
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    if (recipeProvider.recipeList
            .isNotEmpty && //i think problem is here the list isn't populated
        index < recipeProvider.recipeList.length) {
      final Recipe recipe = recipeProvider.recipeList[index]; //get the list
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RecipeDetailsPage(recipe: recipe, currentUser: currentUser),
        ),
      );
    } else {
      print("Error: Recipe list is empty or index is out of range.");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> generateRecipe(
      MealType mealType, BuildContext buildContext) async {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    // Clear the existing recipes
    setState(() {
      _isLoading = true;
      recipeProvider.recipeList.clear();
    });

    String category = mealType.name;
    String unsplashKey = dotenv.env['UNSPLASH_ACCESS_KEY']!;

    // Updated prompt to request multiple recipes with varying difficulty levels
    var prompt =
        "The user $currentUser is requesting $category recipes based on their inventory which includes $_inventory."
        "Remember that not every item in their $_inventory needs to be included in the recipe."
        "Soup items are welcome as well."
        "Please suggest 2-5 recipes of varying difficulty levels and return them in a JSON format."
        "Always include at least 2 vegetarian options, one easy and one medium"
        "The JSON for each recipe must strictly follow this data schema: {name: string, description: string, cookingTime: string, tags: List<String>}"
        "Include the origin of food in the tags."
        "Do not reply with any additional information other than the recipes in JSON format."
        "Do not include formatting in the JSON response.";
    final content = [Content.text(prompt)];

    try {
      final response = await model.generateContent(content);
      if (response.text == null || response.text!.isEmpty) {
        throw FormatException('Empty response from the model - recipe');
      }

      final List<dynamic> recipesList =
          jsonDecode(response.text!) as List<dynamic>;
      for (final recipeData in recipesList) {
        final map = recipeData as Map<String, dynamic>;

        // Fetch image from Unsplash API
        String foodName = map['name'];
        final imageUrl = await http.get(Uri.parse(
            'https://api.unsplash.com/search/photos/?client_id=$unsplashKey&query=$foodName'));

        if (imageUrl.statusCode == 200) {
          final imageMap = jsonDecode(imageUrl.body) as Map<String, dynamic>;
          final image = imageMap['results'][0]['urls']['regular'];
          map['imageUrl'] = image;
        } else {
          print('Unsplash API error: ${imageUrl.statusCode}');
          map['imageUrl'] =
              'https://cdn-icons-png.flaticon.com/512/6478/6478111.png';
        }

        // Fetch Ingredients from Gemini API (seperately due to token limit)
        var ingredientPrompt =
            "The user $currentUser is requesting for a $category recipe based on their inventory which includes $_inventory."
            "You may generate the ingredients list based on items in the inventory and additional items that are needed but isn't present in the user's inventory."
            "The recipe you have recommended is $foodName. As such, you must generate the ingredients needed for this dish"
            "The JSON for ingredients must strictly follow this data schema: {\"ingredients\": Map<String, String>, \"nutrition\": Map<String, String>}, \"allergens\": List<String>}"
            "The first String is the ingredient name and the second String is the quantity. You may include measurements unit in the quantity"
            "The nutrition is the nutritional information of the recipe. The key is the nutritional information and the value is the quantity."
            "The allergens is the list of allergens in the recipe."
            "Do not reply any additional information other than purely the JSON."
            "Do not include the formatting in the JSON response.";
        final ingredientContent = [Content.text(ingredientPrompt)];
        final ingredientResponse =
            await model.generateContent(ingredientContent);
        if (ingredientResponse.text == null ||
            ingredientResponse.text!.isEmpty) {
          throw FormatException('Empty response from the model - ingredients');
        }
        final ingredientMap =
            jsonDecode(ingredientResponse.text!) as Map<String, dynamic>;

        // Fetch Instructions from Gemini API (seperately due to token limit)
        var instructionPrompt =
            "The user $currentUser is requesting for a $category recipe based on their inventory which includes $_inventory."
            "You need to generate the instructions based on the recipe you have recommended."
            "The recipe you have recommended is $foodName. As such, you must generate the instructions needed for this dish"
            "The ingredients you have recommended are $ingredientMap, so follow these ingredients strictly."
            "However, your instruction strictly must never involve the ingredients that are not listed in the ingredients JSON"
            "The JSON for instructions must strictly follow this data schema: {\"instructions\": Map<String, String>}"
            "The key is the step number in this format (Step 1, Step 2, Step 3, etc) and the value is the instruction for that step."
            "Do not reply any additional information other than the instructions JSON."
            "Do not include the formatting in the JSON response.";
        final instructionContent = [Content.text(instructionPrompt)];
        final instructionResponse =
            await model.generateContent(instructionContent);
        if (instructionResponse.text == null ||
            instructionResponse.text!.isEmpty) {
          throw FormatException('Empty response from the model - instructions');
        }
        final instructionMap =
            jsonDecode(instructionResponse.text!) as Map<String, dynamic>;

        final recipe = Recipe(
          name: map['name'],
          imageUrl: map['imageUrl'],
          description: map['description'],
          cookingTime: map['cookingTime'],
          tags: List<String>.from(map['tags']),
          ingredients: Map<String, String>.from(ingredientMap['ingredients']),
          instructions:
              Map<String, String>.from(instructionMap['instructions']),
          nutritions: Map<String, String>.from(ingredientMap['nutrition']),
          allergens: List<String>.from(ingredientMap['allergens']),
        );

        // Add the new recipe to the list
        setState(() {
          _isLoading = false;
          recipeProvider.recipeList.add(recipe);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    final RecipeProvider recipeProvider =
        Provider.of<RecipeProvider>(context, listen: false);
    final MealTypeProvider mealTypeProvider =
        Provider.of<MealTypeProvider>(context, listen: false);

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
                  child: _isLoading
                      ? Container(
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                          width: 10,
                          height: 10,
                        )
                      : ListView.builder(
                          itemCount: recipeProvider.recipeList.length,
                          itemBuilder: (context, index) {
                            final Recipe recipe =
                                recipeProvider.recipeList[index];
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
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    GestureDetector(
                                      onTap: () =>
                                          _navigateToRecipeDetails(index),
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        padding: const EdgeInsets.all(10),
                                        alignment: Alignment.center,
                                        width: width * 0.4,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(32),
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
                hint: mealTypeProvider.isEmpty()
                    ? Text("What meal are you cooking?")
                    : Text(
                        mealTypeProvider.mealType.toString().split('.').last),
                iconSize: 0,
                decoration: AppTheme.recipeDropdownMenu,
                items: MealType.values.map((MealType type) {
                  return DropdownMenuItem<MealType>(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (MealType? newValue) {
                  generateRecipe(newValue!, context);
                  mealTypeProvider.setMealType(newValue);
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
