import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          //background
          Positioned.fill(
            child: Image.asset(
              'lib/images/onboardingpage2.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
