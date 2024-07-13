
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongo/utils/theme/theme.dart';
import 'package:rongo/utils/utils.dart';
import 'package:rongo/widgets/button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});



  @override
  Widget build(BuildContext context) {
    void navigate(){
      Navigator.pushNamed(context, '/scanner');
    }
   

    return Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child:  CustomizedButton(
            title: "Scanner", func: navigate
          ,
          ),
        ),
      ),
    );
  }
}
