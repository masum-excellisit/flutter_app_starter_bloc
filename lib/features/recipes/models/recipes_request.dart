class RecipeRequest {
  final String name;
  final String cuisine;
  final List<String> tags;
  final int userId;

  const RecipeRequest({
    required this.name,
    required this.cuisine,
    this.tags = const [],
    this.userId = 1,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'cuisine': cuisine,
        'tags': tags,
        'userId': userId,
      };
}
