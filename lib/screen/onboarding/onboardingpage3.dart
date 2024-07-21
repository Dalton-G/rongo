import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          //background
          Positioned.fill(
            child: Image.asset('lib/images/onboardingpage3.png',
                fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}
