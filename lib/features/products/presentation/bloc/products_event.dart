part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();
  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductsEvent {}

class LoadProductDetail extends ProductsEvent {
  final int id;
  const LoadProductDetail({required this.id});
  @override
  List<Object> get props => [id];
}

class SearchProducts extends ProductsEvent {
  final String query;
  const SearchProducts({required this.query});
  @override
  List<Object> get props => [query];
}
