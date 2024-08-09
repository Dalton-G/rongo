class Recipe {
  final String name;
  final String description;
  final String imageUrl;
  final String cookingTime;
  final List<String> tags;
  final Map<String, String> ingredients;
  final Map<String, String> missingIngredients;

  Recipe({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cookingTime,
    required this.tags,
    required this.ingredients,
    required this.missingIngredients,
  });
}
