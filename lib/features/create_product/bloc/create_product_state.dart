import 'package:equatable/equatable.dart';
import '../models/product_model.dart';

enum CreateProductStatus { initial, loading, success, failure }

class CreateProductState extends Equatable {
  final CreateProductStatus status;
  final ProductModel? product;
  final String? errorMessage;

  const CreateProductState({
    this.status = CreateProductStatus.initial,
    this.product,
    this.errorMessage,
  });

  CreateProductState copyWith({
    CreateProductStatus? status,
    ProductModel? product,
    String? errorMessage,
  }) {
    return CreateProductState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, product, errorMessage];
}
