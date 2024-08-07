class Recipe {
  final String name;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> nutritionalValue;
  final String cookingTime;
  final List<String> tags;

  Recipe({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.nutritionalValue,
    required this.cookingTime,
    required this.tags,
  });
}
