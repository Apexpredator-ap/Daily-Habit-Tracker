import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:untitled3/core/error/failures.dart';
import 'package:untitled3/core/usecases/usecase.dart';
import 'package:untitled3/features/habits/domain/entities/habit_entity.dart';
import 'package:untitled3/features/habits/domain/repositories/habits_repository.dart';

class CreateHabitParams extends Equatable {
  final String userId;
  final String title;
  final int points;
  final String? description;

  const CreateHabitParams({
    required this.userId,
    required this.title,
    required this.points,
    this.description,
  });

  @override
  List<Object?> get props => [userId, title, points, description];
}

class CreateHabitUseCase implements UseCase<HabitEntity, CreateHabitParams> {
  final HabitsRepository repository;

  CreateHabitUseCase(this.repository);

  static const int minPoints = 1;
  static const int maxPoints = 1000;

  @override
  Future<Either<Failure, HabitEntity>> call(CreateHabitParams params) async {
    final trimmedTitle = params.title.trim();
    if (trimmedTitle.isEmpty) {
      return const Left(ValidationFailure('Habit title cannot be empty'));
    }
    if (params.points < minPoints || params.points > maxPoints) {
      return Left(
        ValidationFailure('Points must be between $minPoints and $maxPoints'),
      );
    }

    return repository.createHabit(
      userId: params.userId,
      title: trimmedTitle,
      points: params.points,
      description: params.description?.trim().isNotEmpty == true
          ? params.description!.trim()
          : null,
    );
  }
}
