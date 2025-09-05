import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  final int totalProducts;
  final int totalUsers;
  final int totalOrders;
  final List<Map<String, dynamic>> recentActivity;

  const DashboardData({
    required this.totalProducts,
    required this.totalUsers,
    required this.totalOrders,
    required this.recentActivity,
  });

  @override
  List<Object> get props =>
      [totalProducts, totalUsers, totalOrders, recentActivity];
}
