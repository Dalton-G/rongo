import 'package:provider/provider.dart';
import 'package:rongo/provider/Item_provider.dart';
import 'package:rongo/provider/onboarding_provider.dart';

class Providers {
  Providers._();

  static final providers = [
    ChangeNotifierProvider<OnboardingProvider>(
      create: (_) => OnboardingProvider(),
    ),
    ChangeNotifierProvider<ItemProvider>(
      create: (_) => ItemProvider(),
    ),
  ].toList();
}
