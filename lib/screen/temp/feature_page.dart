import 'package:flutter/material.dart';
import 'package:rongo/widgets/button.dart';

class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomizedButton(
              title: "Onboarding",
              func: () => Navigator.pushNamed(context, '/onboarding'),
            ),
            CustomizedButton(
              title: "Recipe",
              func: () => Navigator.pushNamed(context, '/recipe-homepage'),
            ),
            CustomizedButton(
              title: "Scanner",
              func: () => Navigator.pushNamed(context, '/scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
