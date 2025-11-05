import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../bloc/create_product_bloc.dart';
import '../bloc/create_product_event.dart';
import '../bloc/create_product_state.dart';
import '../widgets/create_product_form.dart';

class CreateProductScreen extends StatelessWidget {
  const CreateProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateProductBloc, CreateProductState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CreateProductStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(state.product);
        } else if (state.status == CreateProductStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to create product'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: AppScaffold(
        appBar: AppBar(title: const Text('Create Product')),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: CreateProductForm(),
        ),
      ),
    );
  }
}
