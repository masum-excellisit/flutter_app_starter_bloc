import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        username: username,
        password: password,
      );

      // Save tokens
      await StorageService.saveTokens(
        result.token,
        result.refreshToken ?? '',
      );

      // Convert user data to UserModel and save
      final userModel = UserModel.fromJson(result.user);
      await StorageService.saveUserData(jsonEncode(userModel.toJson()));

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
      );

      // Save tokens
      await StorageService.saveTokens(
        result.token,
        result.refreshToken ?? '',
      );

      // Convert user data to UserModel and save
      final userModel = UserModel.fromJson(result.user);
      await StorageService.saveUserData(jsonEncode(userModel.toJson()));

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();

      // Clear local storage
      await StorageService.clearTokens();
      await StorageService.clearUserData();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // First check local storage
      final userData = await StorageService.getUserData();
      if (userData != null) {
        final userJson = jsonDecode(userData);
        final userModel = UserModel.fromJson(userJson);
        return Right(userModel.toEntity());
      }

      // If not found locally, fetch from remote
      final userModel = await remoteDataSource.getCurrentUser();
      await StorageService.saveUserData(jsonEncode(userModel.toJson()));

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final hasToken = await StorageService.hasAccessToken();
      return Right(hasToken);
    } catch (e) {
      return Left(UnknownFailure('Failed to check login status'));
    }
  }
}
