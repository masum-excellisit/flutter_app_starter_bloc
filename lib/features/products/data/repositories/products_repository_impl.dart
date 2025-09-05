import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;
  ProductsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts(
      {int skip = 0, int limit = 20}) async {
    try {
      final products =
          await remoteDataSource.getProducts(skip: skip, limit: limit);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Failed to get products'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductDetail(int id) async {
    try {
      final product = await remoteDataSource.getProductDetail(id);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure('Failed to get product detail'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final products = await remoteDataSource.searchProducts(query);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Failed to search products'));
    }
  }
}
