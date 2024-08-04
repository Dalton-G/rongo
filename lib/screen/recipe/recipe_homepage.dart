import 'package:flutter/material.dart';
import 'package:rongo/model/recipe_meal_type.dart';
import 'package:rongo/utils/theme/theme.dart';

class RecipeHomePage extends StatefulWidget {
  const RecipeHomePage({super.key});

  @override
  State<RecipeHomePage> createState() => _RecipeHomePageState();
}

class _RecipeHomePageState extends State<RecipeHomePage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;

    return Scaffold(
      body: Stack(
        children: [
          // background image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'lib/images/recipeHomePage.png',
              fit: BoxFit.cover,
            ),
          ),
          // recipe overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                height: height * 0.70,
                width: width,
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Nothing to see here!"),
                    Text("Start generating recipes now!"),
                  ],
                ),
              ),
            ),
          ),
          // dropdown overlay
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: height * 0.15),
              width: width * 0.9,
              child: DropdownButtonFormField<MealType>(
                hint: const Text("What meal are you cooking?"),
                iconSize: 0,
                decoration: AppTheme.recipeDropdownMenu,
                items: MealType.values.map((MealType type) {
                  return DropdownMenuItem<MealType>(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (MealType? newValue) {
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
      // trigger chatbot
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 10, 70),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () => Navigator.pushNamed(context, '/chat'),
          backgroundColor: AppTheme.backgroundWhite,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              'lib/images/rongie.png',
            ),
          ),
        ),
      ),
    );
  }
}
