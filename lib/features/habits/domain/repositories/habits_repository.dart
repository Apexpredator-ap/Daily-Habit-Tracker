import 'package:dartz/dartz.dart';
import 'package:untitled3/core/error/failures.dart';
import 'package:untitled3/features/habits/domain/entities/completion_entity.dart';
import 'package:untitled3/features/habits/domain/entities/habit_entity.dart';
import 'package:untitled3/features/habits/domain/entities/habit_with_today_status.dart';
import 'package:untitled3/features/streaks/domain/entities/streak_info.dart';

abstract class HabitsRepository {
  /// Reactive stream of active habits along with today's completion status
  Stream<Either<Failure, List<HabitWithTodayStatus>>> watchTodayHabits({
    required String userId,
    required String dateKey,
  });

  /// Create a new habit
  Future<Either<Failure, HabitEntity>> createHabit({
    required String userId,
    required String title,
    required int points,
    String? description,
  });

  /// Toggle habit completion status for a specific dateKey
  Future<Either<Failure, CompletionEntity>> toggleHabitCompletion({
    required String userId,
    required String habitId,
    required String dateKey,
    required bool isCompleted,
    required int points,
  });

  /// Archive a habit (soft delete)
  Future<Either<Failure, void>> archiveHabit({
    required String userId,
    required String habitId,
  });

  /// Get streak information for all active habits
  Future<Either<Failure, List<StreakInfo>>> getHabitStreaks({
    required String userId,
    DateTime? referenceDate,
  });
}
