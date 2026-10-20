import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:untitled3/core/error/failures.dart';
import 'package:untitled3/core/usecases/usecase.dart';
import 'package:untitled3/features/habits/domain/entities/habit_with_today_status.dart';
import 'package:untitled3/features/habits/domain/repositories/habits_repository.dart';

class WatchTodayHabitsParams extends Equatable {
  final String userId;
  final String dateKey;

  const WatchTodayHabitsParams({required this.userId, required this.dateKey});

  @override
  List<Object?> get props => [userId, dateKey];
}

class WatchTodayHabitsUseCase
    implements
        StreamUseCase<List<HabitWithTodayStatus>, WatchTodayHabitsParams> {
  final HabitsRepository repository;

  WatchTodayHabitsUseCase(this.repository);

  @override
  Stream<Either<Failure, List<HabitWithTodayStatus>>> call(
    WatchTodayHabitsParams params,
  ) {
    return repository.watchTodayHabits(
      userId: params.userId,
      dateKey: params.dateKey,
    );
  }
}
