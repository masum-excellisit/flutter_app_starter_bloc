import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/dashboard_data.dart';

abstract class HomeRemoteDataSource {
  Future<DashboardData> getDashboardData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DashboardData> getDashboardData() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      return const DashboardData(
        totalProducts: 150,
        totalUsers: 1250,
        totalOrders: 320,
        recentActivity: [
          {'type': 'order', 'message': 'New order #1234', 'time': '2 min ago'},
          {
            'type': 'user',
            'message': 'New user registered',
            'time': '5 min ago'
          },
          {
            'type': 'product',
            'message': 'Product updated',
            'time': '10 min ago'
          },
        ],
      );
    } catch (e) {
      throw ServerException('Failed to fetch dashboard data');
    }
  }
}
