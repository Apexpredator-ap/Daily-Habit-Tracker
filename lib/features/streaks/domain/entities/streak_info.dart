import 'package:equatable/equatable.dart';

class DayCompletionItem extends Equatable {
  final DateTime date;
  final String dateKey;
  final bool isCompleted;

  const DayCompletionItem({
    required this.date,
    required this.dateKey,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [date, dateKey, isCompleted];
}

class StreakInfo extends Equatable {
  final String habitId;
  final String habitTitle;
  final int currentStreak;
  final int longestStreak;
  final List<DayCompletionItem> last7Days;

  const StreakInfo({
    required this.habitId,
    required this.habitTitle,
    required this.currentStreak,
    required this.longestStreak,
    required this.last7Days,
  });

  @override
  List<Object?> get props => [
    habitId,
    habitTitle,
    currentStreak,
    longestStreak,
    last7Days,
  ];
}
