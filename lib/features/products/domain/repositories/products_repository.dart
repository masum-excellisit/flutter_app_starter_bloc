import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';

abstract class ProductsRepository {
  Future<Either<Failure, List<Product>>> getProducts(
      {int skip = 0, int limit = 20});
  Future<Either<Failure, Product>> getProductDetail(int id);
  Future<Either<Failure, List<Product>>> searchProducts(String query);
}
