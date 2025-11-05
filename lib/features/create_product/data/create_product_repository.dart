import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_response.dart';
import '../api/create_product_api.dart';
import '../models/product_model.dart';

class CreateProductRepository {
  final CreateProductApi _api;

  CreateProductRepository(this._api);

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final ApiResponse<ProductModel> response = await _api.createProduct(data);

    if (response.data != null) {
      return response.data!;
    }

    throw ServerException(
      response.errorMessage ?? 'Failed to create product',
      statusCode: response.statusCode,
    );
  }
}
