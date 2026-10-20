import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:untitled3/core/error/exceptions.dart';
import 'package:untitled3/core/error/failures.dart';
import 'package:untitled3/features/habits/data/datasources/habits_remote_data_source.dart';
import 'package:untitled3/features/habits/data/models/completion_model.dart';
import 'package:untitled3/features/habits/data/models/habit_model.dart';
import 'package:untitled3/features/habits/domain/entities/completion_entity.dart';
import 'package:untitled3/features/habits/domain/entities/habit_entity.dart';
import 'package:untitled3/features/habits/domain/entities/habit_with_today_status.dart';
import 'package:untitled3/features/habits/domain/repositories/habits_repository.dart';
import 'package:untitled3/features/streaks/domain/entities/streak_info.dart';
import 'package:untitled3/features/streaks/domain/services/streak_calculator.dart';
import 'package:uuid/uuid.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  final HabitsRemoteDataSource remoteDataSource;
  final StreakCalculator streakCalculator;
  final Uuid _uuid;

  HabitsRepositoryImpl({
    required this.remoteDataSource,
    required this.streakCalculator,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  @override
  Stream<Either<Failure, List<HabitWithTodayStatus>>> watchTodayHabits({
    required String userId,
    required String dateKey,
  }) {
    try {
      return remoteDataSource
          .watchHabits(userId)
          .asyncMap((habits) async {
            try {
              final List<HabitWithTodayStatus> results = [];
              for (final habit in habits) {
                // Fetch completions for today
                final completions = await remoteDataSource
                    .getAllCompletionsForHabit(
                      userId: userId,
                      habitId: habit.id,
                    );
                final todayCompletion = completions.firstWhere(
                  (c) => c.dateKey == dateKey,
                  orElse: () => CompletionModel(
                    dateKey: dateKey,
                    habitId: habit.id,
                    isCompleted: false,
                    pointsEarned: 0,
                    completedAt: DateTime.now(),
                  ),
                );

                results.add(
                  HabitWithTodayStatus(
                    habit: habit,
                    todayCompletion: todayCompletion.isCompleted
                        ? todayCompletion
                        : null,
                  ),
                );
              }
              return Right<Failure, List<HabitWithTodayStatus>>(results);
            } catch (e) {
              return Left<Failure, List<HabitWithTodayStatus>>(
                ServerFailure('Failed to load habit status: $e'),
              );
            }
          })
          .handleError((error) {
            return Left<Failure, List<HabitWithTodayStatus>>(
              ServerFailure(error.toString()),
            );
          });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to subscribe to habits: $e')),
      );
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> createHabit({
    required String userId,
    required String title,
    required int points,
    String? description,
  }) async {
    try {
      final now = DateTime.now();
      final newHabit = HabitModel(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        description: description,
        points: points,
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      );

      final created = await remoteDataSource.createHabit(newHabit);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompletionEntity>> toggleHabitCompletion({
    required String userId,
    required String habitId,
    required String dateKey,
    required bool isCompleted,
    required int points,
  }) async {
    try {
      final completion = CompletionModel(
        dateKey: dateKey,
        habitId: habitId,
        isCompleted: isCompleted,
        pointsEarned: isCompleted ? points : 0,
        completedAt: DateTime.now(),
      );

      final result = await remoteDataSource.setCompletion(
        userId: userId,
        habitId: habitId,
        completion: completion,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> archiveHabit({
    required String userId,
    required String habitId,
  }) async {
    try {
      await remoteDataSource.archiveHabit(userId, habitId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StreakInfo>>> getHabitStreaks({
    required String userId,
    DateTime? referenceDate,
  }) async {
    try {
      // Get all non-archived habits
      final habitsStream = remoteDataSource.watchHabits(userId);
      final habits = await habitsStream.first;

      final List<StreakInfo> streakList = [];
      for (final habit in habits) {
        final completions = await remoteDataSource.getAllCompletionsForHabit(
          userId: userId,
          habitId: habit.id,
        );
        final streak = streakCalculator.calculate(
          habit: habit,
          completions: completions,
          referenceDate: referenceDate,
        );
        streakList.add(streak);
      }

      return Right(streakList);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
