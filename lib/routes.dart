import 'package:flutter/material.dart';
import 'package:rongo/screen/home/homepage.dart';
import 'package:rongo/screen/onboarding/onboarding.dart';
import 'package:rongo/screen/recipe/recipe_homepage.dart';
import 'package:rongo/screen/scan_and_add/scanner.dart';
import 'package:rongo/screen/notes/notespage.dart';

class Routes {
  Routes._();

  static const String onboarding = '/onboarding';
  static const String scanner = '/scanner';
  static const String homepage = '/homepage';
  static const String recipeHomepage = '/recipe-homepage';
  static const String notespage = '/notespage';

  static final dynamic routes = <String, WidgetBuilder>{
    onboarding: (BuildContext context) => const OnboardingPage(),
    scanner: (BuildContext context) => const Scanner(),
    homepage: (BuildContext context) => const HomePage(),
    recipeHomepage: (BuildContext context) => const RecipeHomePage(),
    notespage: (BuildContext context) => const NotesPage(),
  };
}
