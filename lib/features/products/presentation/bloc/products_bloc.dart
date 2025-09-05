import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductDetailUseCase getProductDetailUseCase;
  final SearchProductsUseCase searchProductsUseCase;

  ProductsBloc({
    required this.getProductsUseCase,
    required this.getProductDetailUseCase,
    required this.searchProductsUseCase,
  }) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductDetail>(_onLoadProductDetail);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    final result = await getProductsUseCase();
    result.fold(
      (failure) => emit(ProductsError(message: failure.message)),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }

  Future<void> _onLoadProductDetail(
      LoadProductDetail event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    final result = await getProductDetailUseCase(event.id);
    result.fold(
      (failure) => emit(ProductsError(message: failure.message)),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }

  Future<void> _onSearchProducts(
      SearchProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    final result = await searchProductsUseCase(event.query);
    result.fold(
      (failure) => emit(ProductsError(message: failure.message)),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }
}
