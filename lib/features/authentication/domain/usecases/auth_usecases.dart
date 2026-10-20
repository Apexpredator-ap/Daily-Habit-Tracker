import 'package:dartz/dartz.dart';
import 'package:untitled3/core/error/failures.dart';
import 'package:untitled3/core/usecases/usecase.dart';
import 'package:untitled3/features/authentication/domain/entities/user_entity.dart';
import 'package:untitled3/features/authentication/domain/repositories/auth_repository.dart';

class SignInAnonymouslyUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  SignInAnonymouslyUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return repository.signInAnonymously();
  }
}

class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
