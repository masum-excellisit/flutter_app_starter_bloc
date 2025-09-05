import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductDetailUseCase {
  final ProductsRepository repository;
  GetProductDetailUseCase(this.repository);

  Future<Either<Failure, Product>> call(int id) async {
    return await repository.getProductDetail(id);
  }
}
