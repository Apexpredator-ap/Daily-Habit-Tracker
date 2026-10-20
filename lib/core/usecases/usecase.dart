import 'package:dartz/dartz.dart';
import 'package:untitled3/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
