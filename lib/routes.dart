import 'package:flutter/material.dart';
import 'package:rongo/screen/onboarding/onboarding.dart';

class Routes {
  Routes._();

  static const String onboarding = '/onboarding';

  static final dynamic routes = <String, WidgetBuilder>{
    onboarding: (BuildContext context) => const OnboardingPage(),
  };
}
