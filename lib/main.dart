import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:rongo/firebase_options.dart';
import 'package:rongo/providers.dart';
import 'package:rongo/routes.dart';
import 'package:rongo/screen/onboarding/onboarding.dart';
import 'package:rongo/utils/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: Providers.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rongo',
        home: const OnboardingPage(),
        theme: AppTheme.lightTheme,
        routes: Routes.routes,
      ),
    );
  }
}
