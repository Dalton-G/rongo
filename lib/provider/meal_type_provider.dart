import 'package:flutter/material.dart';
import 'package:rongo/model/recipe_meal_type.dart';

class MealTypeProvider extends ChangeNotifier {
  MealType? _mealType;

  MealType? get mealType => _mealType;

  void setMealType(MealType mealType) {
    _mealType = mealType;
    notifyListeners();
  }

  bool isEmpty() {
    return _mealType == null;
  }
}
