import 'package:flutter/material.dart';
import '../../core/modules/crud_module.dart';
import '../../core/network/api_urls.dart';
import 'models/recipes_model.dart';
import 'models/recipes_request.dart';
import 'screens/recipes_screen.dart';

class RecipesModule {
  static Widget route() {
    return CrudModule.route<RecipeModel, RecipeRequest, RecipeRequest, int>(
      child: const RecipesScreen(),
      fromJson: RecipeModel.fromJson,
      toJson: (x) => x.toJson(),
      idSelectorFn: (x) => x.id,
      baseEndpoint: EndPoints.recipes,
      createEndpoint: EndPoints.recipesAdd,
      updateEndpointPrefix: EndPoints.recipes,
      itemsKey: 'recipes',
      createMapper: (r) => r.toJson(),
      updateMapper: (r) => r.toJson(),
    );
  }
}
