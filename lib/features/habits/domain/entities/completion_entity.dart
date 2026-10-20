import 'package:equatable/equatable.dart';

class CompletionEntity extends Equatable {
  final String dateKey; // yyyy-MM-dd in user's local timezone
  final String habitId;
  final bool isCompleted;
  final int pointsEarned;
  final DateTime completedAt;

  const CompletionEntity({
    required this.dateKey,
    required this.habitId,
    required this.isCompleted,
    required this.pointsEarned,
    required this.completedAt,
  });

  @override
  List<Object?> get props => [
    dateKey,
    habitId,
    isCompleted,
    pointsEarned,
    completedAt,
  ];
}
