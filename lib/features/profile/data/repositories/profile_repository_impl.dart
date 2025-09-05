import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    try {
      final data = await remoteDataSource.getProfile();
      final profile = Profile(
        id: data['id'],
        name: data['name'],
        email: data['email'],
      );
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure('Failed to get profile'));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(Profile profile) async {
    try {
      final data = await remoteDataSource.updateProfile({
        'id': profile.id,
        'name': profile.name,
        'email': profile.email,
      });
      final updatedProfile = Profile(
        id: data['id'],
        name: data['name'],
        email: data['email'],
      );
      return Right(updatedProfile);
    } catch (e) {
      return Left(ServerFailure('Failed to update profile'));
    }
  }
}
