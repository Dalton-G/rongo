import 'package:flutter/material.dart';
import 'package:rongo/screen/onboarding/onboarding.dart';
import 'package:rongo/screen/recipe/recipe_homepage.dart';
import 'package:rongo/screen/scan_and_add/scanner.dart';

class Routes {
  Routes._();

  static const String onboarding = '/onboarding';
  static const String scanner = '/scanner';
  static const String recipeHomepage = '/recipe-homepage';

  static final dynamic routes = <String, WidgetBuilder>{
    onboarding: (BuildContext context) => const OnboardingPage(),
    scanner: (BuildContext context) => const Scanner(),
    recipeHomepage: (BuildContext context) => const RecipeHomePage(),
  };
}
