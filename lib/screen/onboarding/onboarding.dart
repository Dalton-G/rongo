import 'package:flutter/material.dart';
import 'package:rongo/screen/onboarding/onboardingpage1.dart';
import 'package:rongo/screen/onboarding/onboardingpage2.dart';
import 'package:rongo/screen/onboarding/onboardingpage3.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/routes.dart';
import 'package:rongo/widgets/button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  //page controller
  PageController _controller = PageController();

  //page index tracker
  int _currentPageIndex = 0;

  //page text
  final List<String> _pageTexts = [
    "Keep your fridge at your fingertips - grocery shopping has never been this easy.",
    "Don't know how to choose your produce? Don't fret - Rongo does it with a scan.",
    "Never know what to do with the ingredients you have? Cook with our AI assistant!",
  ];

  //functions
  void _navToHomePage() {
    Navigator.pushNamed(context, Routes.scanner);
  }

  @override
  Widget build(BuildContext context) {
    //page dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            children: [
              OnboardingPage1(),
              OnboardingPage2(),
              OnboardingPage3(),
            ],
          ),

          //bottom image
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Image.asset(
              'lib/images/bottomcircle.png',
              fit: BoxFit.cover,
            ),
          ),

          //rongo logo
          Positioned(
            top: screenHeight / 1.60,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 200,
                child: Image.asset('lib/images/rongologo.png'),
              ),
            ),
          ),

          //descriptor text
          Positioned(
            top: screenHeight / 1.30,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 300,
                child: Text(
                  _pageTexts[_currentPageIndex],
                  style: AppTheme.blackBodyText,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          //get startedbutton
          Positioned(
            top: screenHeight / 1.13,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: DefaultButton(
                backgroundColor: AppTheme.mainGreen,
                func: _navToHomePage,
                roundedCorner: 25,
                buttonText: "Get Started",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
