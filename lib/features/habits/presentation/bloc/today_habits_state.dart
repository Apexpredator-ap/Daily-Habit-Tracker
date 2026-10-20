import 'package:equatable/equatable.dart';
import 'package:untitled3/features/habits/domain/entities/habit_with_today_status.dart';

abstract class TodayHabitsEvent extends Equatable {
  const TodayHabitsEvent();
  @override
  List<Object?> get props => [];
}

class WatchTodayHabitsStarted extends TodayHabitsEvent {
  final String userId;
  final String dateKey;

  const WatchTodayHabitsStarted({required this.userId, required this.dateKey});

  @override
  List<Object?> get props => [userId, dateKey];
}

class HabitsUpdated extends TodayHabitsEvent {
  final List<HabitWithTodayStatus> habits;

  const HabitsUpdated(this.habits);

  @override
  List<Object?> get props => [habits];
}

class HabitsErrorReceived extends TodayHabitsEvent {
  final String message;

  const HabitsErrorReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class ToggleHabitRequested extends TodayHabitsEvent {
  final String habitId;
  final bool isCompleted;
  final int points;

  const ToggleHabitRequested({
    required this.habitId,
    required this.isCompleted,
    required this.points,
  });

  @override
  List<Object?> get props => [habitId, isCompleted, points];
}

class ArchiveHabitRequested extends TodayHabitsEvent {
  final String habitId;

  const ArchiveHabitRequested(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

abstract class TodayHabitsState extends Equatable {
  const TodayHabitsState();
  @override
  List<Object?> get props => [];
}

class TodayHabitsInitial extends TodayHabitsState {}

class TodayHabitsLoading extends TodayHabitsState {}

class TodayHabitsLoaded extends TodayHabitsState {
  final List<HabitWithTodayStatus> habits;
  final String dateKey;
  final Set<String> pendingToggleHabitIds;

  const TodayHabitsLoaded({
    required this.habits,
    required this.dateKey,
    this.pendingToggleHabitIds = const {},
  });

  int get totalPointsEarnedToday {
    return habits
        .where((h) => h.isCompletedToday)
        .fold(0, (sum, h) => sum + h.habit.points);
  }

  int get completedHabitsCount {
    return habits.where((h) => h.isCompletedToday).length;
  }

  int get totalHabitsCount => habits.length;

  double get completionPercentage {
    if (totalHabitsCount == 0) return 0.0;
    return completedHabitsCount / totalHabitsCount;
  }

  bool get isEmpty => habits.isEmpty;

  TodayHabitsLoaded copyWith({
    List<HabitWithTodayStatus>? habits,
    String? dateKey,
    Set<String>? pendingToggleHabitIds,
  }) {
    return TodayHabitsLoaded(
      habits: habits ?? this.habits,
      dateKey: dateKey ?? this.dateKey,
      pendingToggleHabitIds:
          pendingToggleHabitIds ?? this.pendingToggleHabitIds,
    );
  }

  @override
  List<Object?> get props => [habits, dateKey, pendingToggleHabitIds];
}

class TodayHabitsError extends TodayHabitsState {
  final String message;

  const TodayHabitsError(this.message);

  @override
  List<Object?> get props => [message];
}
