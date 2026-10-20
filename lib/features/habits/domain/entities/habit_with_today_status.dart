import 'package:equatable/equatable.dart';
import 'package:untitled3/features/habits/domain/entities/completion_entity.dart';
import 'package:untitled3/features/habits/domain/entities/habit_entity.dart';

class HabitWithTodayStatus extends Equatable {
  final HabitEntity habit;
  final CompletionEntity? todayCompletion;

  const HabitWithTodayStatus({required this.habit, this.todayCompletion});

  bool get isCompletedToday => todayCompletion?.isCompleted ?? false;
  int get pointsEarnedToday => isCompletedToday ? habit.points : 0;

  HabitWithTodayStatus copyWith({
    HabitEntity? habit,
    CompletionEntity? todayCompletion,
  }) {
    return HabitWithTodayStatus(
      habit: habit ?? this.habit,
      todayCompletion: todayCompletion ?? this.todayCompletion,
    );
  }

  @override
  List<Object?> get props => [habit, todayCompletion];
}
