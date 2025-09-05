import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository repository;
  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call(
      {int skip = 0, int limit = 20}) async {
    return await repository.getProducts(skip: skip, limit: limit);
  }
}
