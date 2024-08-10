class Recipe {
  final String name;
  final String description;
  final String imageUrl;
  final String cookingTime;
  final List<String> tags;
  final Map<String, String> ingredients;
  final Map<String, String> instructions;
  final Map<String, String> nutritions;
  final List<String> allergens;

  Recipe({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cookingTime,
    required this.tags,
    required this.ingredients,
    required this.instructions,
    required this.nutritions,
    required this.allergens,
  });
}
