import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:untitled3/core/error/failures.dart';
import 'package:untitled3/core/usecases/usecase.dart';
import 'package:untitled3/features/habits/domain/repositories/habits_repository.dart';
import 'package:untitled3/features/streaks/domain/entities/streak_info.dart';

class GetHabitStreaksParams extends Equatable {
  final String userId;
  final DateTime? referenceDate;

  const GetHabitStreaksParams({required this.userId, this.referenceDate});

  @override
  List<Object?> get props => [userId, referenceDate];
}

class GetHabitStreaksUseCase
    implements UseCase<List<StreakInfo>, GetHabitStreaksParams> {
  final HabitsRepository repository;

  GetHabitStreaksUseCase(this.repository);

  @override
  Future<Either<Failure, List<StreakInfo>>> call(GetHabitStreaksParams params) {
    return repository.getHabitStreaks(
      userId: params.userId,
      referenceDate: params.referenceDate,
    );
  }
}
