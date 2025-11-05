import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/api_urls.dart';
import '../models/product_model.dart';

class CreateProductApi {
  final ApiClient _client;

  CreateProductApi(this._client);

  Future<ApiResponse<ProductModel>> createProduct(Map<String, dynamic> data) {
    return _client.postRequest<ProductModel>(
      endPoint: EndPoints.productsAdd,
      reqModel: data,
      fromJson: (json) => ProductModel.fromJson(json),
    );
  }
}
