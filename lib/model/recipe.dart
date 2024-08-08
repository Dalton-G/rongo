class Recipe {
  final String name;
  final String description;
  final String imageUrl;
  final String cookingTime;
  final List<String> tags;

  Recipe({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cookingTime,
    required this.tags,
  });
}
