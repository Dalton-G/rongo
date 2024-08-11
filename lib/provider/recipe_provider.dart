import 'package:flutter/material.dart';
import 'package:rongo/model/recipe.dart';

class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipeList = [];

  List<Recipe> get recipeList => _recipeList;

  void addRecipe(Recipe recipe) {
    _recipeList.add(recipe);
    notifyListeners();
  }

  void clearRecipe() {
    _recipeList.clear();
    notifyListeners();
  }
}
