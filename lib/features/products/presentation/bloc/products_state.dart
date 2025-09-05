part of 'products_bloc.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();
  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  const ProductsLoaded({required this.products});
  @override
  List<Object> get props => [products];
}

class ProductDetailLoaded extends ProductsState {
  final Product product;
  const ProductDetailLoaded({required this.product});
  @override
  List<Object> get props => [product];
}

class ProductsError extends ProductsState {
  final String message;
  const ProductsError({required this.message});
  @override
  List<Object> get props => [message];
}
