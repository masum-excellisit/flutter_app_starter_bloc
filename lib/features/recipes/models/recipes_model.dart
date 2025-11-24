class RecipesModel {
  List<RecipeModel>? recipes;
  int? total;
  int? skip;
  int? limit;

  RecipesModel({this.recipes, this.total, this.skip, this.limit});

  RecipesModel.fromJson(Map<String, dynamic> json) {
    if (json['recipes'] != null) {
      recipes = <RecipeModel>[];
      json['recipes'].forEach((v) {
        recipes!.add(new RecipeModel.fromJson(v));
      });
    }
    total = json['total'];
    skip = json['skip'];
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.recipes != null) {
      data['recipes'] = this.recipes!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['skip'] = this.skip;
    data['limit'] = this.limit;
    return data;
  }
}

class RecipeModel {
  late int id;
  String? name;
  List<String>? ingredients;
  List<String>? instructions;
  int? prepTimeMinutes;
  int? cookTimeMinutes;
  int? servings;
  String? difficulty;
  String? cuisine;
  int? caloriesPerServing;
  List<String>? tags;
  int? userId;
  String? image;
  double? rating;
  int? reviewCount;
  List<String>? mealType;

  RecipeModel(
      {required this.id,
      this.name,
      this.ingredients,
      this.instructions,
      this.prepTimeMinutes,
      this.cookTimeMinutes,
      this.servings,
      this.difficulty,
      this.cuisine,
      this.caloriesPerServing,
      this.tags,
      this.userId,
      this.image,
      this.rating,
      this.reviewCount,
      this.mealType});

  RecipeModel.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt() ?? 0;
    name = json['name'] as String?;
    ingredients = (json['ingredients'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();
    instructions = (json['instructions'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();
    prepTimeMinutes = (json['prepTimeMinutes'] as num?)?.toInt();
    cookTimeMinutes = (json['cookTimeMinutes'] as num?)?.toInt();
    servings = (json['servings'] as num?)?.toInt();
    difficulty = json['difficulty'] as String?;
    cuisine = json['cuisine'] as String?;
    caloriesPerServing = (json['caloriesPerServing'] as num?)?.toInt();
    tags = (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    userId = (json['userId'] as num?)?.toInt();
    image = json['image'] as String?;
    rating =
        (json['rating'] is num) ? (json['rating'] as num).toDouble() : null;
    reviewCount = (json['reviewCount'] as num?)?.toInt();
    mealType =
        (json['mealType'] as List<dynamic>?)?.map((e) => e.toString()).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['ingredients'] = this.ingredients;
    data['instructions'] = this.instructions;
    data['prepTimeMinutes'] = this.prepTimeMinutes;
    data['cookTimeMinutes'] = this.cookTimeMinutes;
    data['servings'] = this.servings;
    data['difficulty'] = this.difficulty;
    data['cuisine'] = this.cuisine;
    data['caloriesPerServing'] = this.caloriesPerServing;
    data['tags'] = this.tags;
    data['userId'] = this.userId;
    data['image'] = this.image;
    data['rating'] = this.rating;
    data['reviewCount'] = this.reviewCount;
    data['mealType'] = this.mealType;
    return data;
  }
}
