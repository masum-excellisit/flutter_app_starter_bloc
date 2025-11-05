import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_client.dart';
import 'api/create_product_api.dart';
import 'bloc/create_product_bloc.dart';
import 'data/create_product_repository.dart';
import 'screens/create_product_screen.dart';

class CreateProductModule {
  static Widget route() {
    final api = CreateProductApi(ApiClient());
    final repository = CreateProductRepository(api);

    return BlocProvider(
      create: (_) => CreateProductBloc(repository),
      child: const CreateProductScreen(),
    );
  }
}
