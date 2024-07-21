import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          //background
          Positioned.fill(
            child: Image.asset(
              'lib/images/onboardingpage1.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
