import 'package:provider/provider.dart';
import 'package:rongo/provider/Item_provider.dart';
import 'package:rongo/provider/chat_provider.dart';
import 'package:rongo/provider/meal_type_provider.dart';
import 'package:rongo/provider/onboarding_provider.dart';
import 'package:rongo/provider/recipe_chat_provider.dart';
import 'package:rongo/provider/recipe_provider.dart';
import 'package:rongo/provider/stt_provider.dart';
import 'package:rongo/screen/home/homepage.dart';

class Providers {
  Providers._();

  static final providers = [
    ChangeNotifierProvider<OnboardingProvider>(
      create: (_) => OnboardingProvider(),
    ),
    ChangeNotifierProvider<ItemProvider>(
      create: (_) => ItemProvider(),
    ),
    ChangeNotifierProvider<IndexProvider>(
      create: (_) => IndexProvider(),
    ),
    ChangeNotifierProvider<SttProvider>(
      create: (_) => SttProvider(),
    ),
    ChangeNotifierProvider<ChatProvider>(
      create: (_) => ChatProvider(),
    ),
    ChangeNotifierProvider<RecipeChatProvider>(
      create: (_) => RecipeChatProvider(),
    ),
    ChangeNotifierProvider<RecipeProvider>(
      create: (_) => RecipeProvider(),
    ),
    ChangeNotifierProvider<MealTypeProvider>(
      create: (_) => MealTypeProvider(),
    ),
  ].toList();
}
