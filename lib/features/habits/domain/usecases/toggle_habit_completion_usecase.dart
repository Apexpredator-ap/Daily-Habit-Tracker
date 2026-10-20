import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:untitled3/core/error/failures.dart';
import 'package:untitled3/core/usecases/usecase.dart';
import 'package:untitled3/features/habits/domain/entities/completion_entity.dart';
import 'package:untitled3/features/habits/domain/repositories/habits_repository.dart';

class ToggleHabitCompletionParams extends Equatable {
  final String userId;
  final String habitId;
  final String dateKey;
  final bool isCompleted;
  final int points;

  const ToggleHabitCompletionParams({
    required this.userId,
    required this.habitId,
    required this.dateKey,
    required this.isCompleted,
    required this.points,
  });

  @override
  List<Object?> get props => [userId, habitId, dateKey, isCompleted, points];
}

class ToggleHabitCompletionUseCase
    implements UseCase<CompletionEntity, ToggleHabitCompletionParams> {
  final HabitsRepository repository;

  ToggleHabitCompletionUseCase(this.repository);

  @override
  Future<Either<Failure, CompletionEntity>> call(
    ToggleHabitCompletionParams params,
  ) {
    return repository.toggleHabitCompletion(
      userId: params.userId,
      habitId: params.habitId,
      dateKey: params.dateKey,
      isCompleted: params.isCompleted,
      points: params.points,
    );
  }
}
