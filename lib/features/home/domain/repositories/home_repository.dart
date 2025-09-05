import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_data.dart';

abstract class HomeRepository {
  Future<Either<Failure, DashboardData>> getDashboardData();
}
