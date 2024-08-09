import 'package:flutter/material.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Object? recipe;
  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  get recipe => widget.recipe;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: const Center(child: Text("Do later")),
    );
  }
}
