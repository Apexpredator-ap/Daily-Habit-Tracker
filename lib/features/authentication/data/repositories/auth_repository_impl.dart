import 'package:dartz/dartz.dart';
import 'package:untitled3/core/error/exceptions.dart';
import 'package:untitled3/core/error/failures.dart';
import 'package:untitled3/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:untitled3/features/authentication/domain/entities/user_entity.dart';
import 'package:untitled3/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<Either<Failure, UserEntity>> signInAnonymously() async {
    try {
      final user = await remoteDataSource.signInAnonymously();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
