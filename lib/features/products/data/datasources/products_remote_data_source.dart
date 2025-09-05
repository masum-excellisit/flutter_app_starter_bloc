import '../../../../core/network/api_client.dart';
import '../../domain/entities/product.dart';

abstract class ProductsRemoteDataSource {
  Future<List<Product>> getProducts({int skip = 0, int limit = 20});
  Future<Product> getProductDetail(int id);
  Future<List<Product>> searchProducts(String query);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final ApiClient apiClient;
  ProductsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Product>> getProducts({int skip = 0, int limit = 20}) async {
    // Stub implementation
    return [
      const Product(
        id: 1,
        title: 'Sample Product',
        description: 'This is a sample product',
        price: 99.99,
        category: 'Electronics',
        image: 'https://via.placeholder.com/150',
        rating: 4.5,
      ),
    ];
  }

  @override
  Future<Product> getProductDetail(int id) async {
    return const Product(
      id: 1,
      title: 'Sample Product',
      description: 'This is a sample product',
      price: 99.99,
      category: 'Electronics',
      image: 'https://via.placeholder.com/150',
      rating: 4.5,
    );
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    return [
      const Product(
        id: 1,
        title: 'Sample Product',
        description: 'This is a sample product',
        price: 99.99,
        category: 'Electronics',
        image: 'https://via.placeholder.com/150',
        rating: 4.5,
      ),
    ];
  }
}
