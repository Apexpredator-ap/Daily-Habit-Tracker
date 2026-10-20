import 'package:equatable/equatable.dart';
import 'package:untitled3/features/habits/domain/entities/habit_entity.dart';

abstract class AddHabitEvent extends Equatable {
  const AddHabitEvent();
  @override
  List<Object?> get props => [];
}

class AddHabitSubmitted extends AddHabitEvent {
  final String userId;
  final String title;
  final int points;
  final String? description;

  const AddHabitSubmitted({
    required this.userId,
    required this.title,
    required this.points,
    this.description,
  });

  @override
  List<Object?> get props => [userId, title, points, description];
}

class AddHabitReset extends AddHabitEvent {}

abstract class AddHabitState extends Equatable {
  const AddHabitState();
  @override
  List<Object?> get props => [];
}

class AddHabitInitial extends AddHabitState {}

class AddHabitSubmitting extends AddHabitState {}

class AddHabitSuccess extends AddHabitState {
  final HabitEntity habit;

  const AddHabitSuccess(this.habit);

  @override
  List<Object?> get props => [habit];
}

class AddHabitFailure extends AddHabitState {
  final String message;

  const AddHabitFailure(this.message);

  @override
  List<Object?> get props => [message];
}
