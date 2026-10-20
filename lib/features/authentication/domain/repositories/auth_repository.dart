import 'package:dartz/dartz.dart';
import 'package:untitled3/core/error/failures.dart';
import 'package:untitled3/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<Either<Failure, UserEntity>> signInAnonymously();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> signOut();
}
