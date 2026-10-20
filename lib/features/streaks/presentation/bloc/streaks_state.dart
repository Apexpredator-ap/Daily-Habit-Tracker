import 'package:equatable/equatable.dart';
import 'package:untitled3/features/streaks/domain/entities/streak_info.dart';

abstract class StreaksEvent extends Equatable {
  const StreaksEvent();
  @override
  List<Object?> get props => [];
}

class LoadStreaksRequested extends StreaksEvent {
  final String userId;
  final DateTime? referenceDate;

  const LoadStreaksRequested({required this.userId, this.referenceDate});

  @override
  List<Object?> get props => [userId, referenceDate];
}

abstract class StreaksState extends Equatable {
  const StreaksState();
  @override
  List<Object?> get props => [];
}

class StreaksInitial extends StreaksState {}

class StreaksLoading extends StreaksState {}

class StreaksLoaded extends StreaksState {
  final List<StreakInfo> streaks;

  const StreaksLoaded(this.streaks);

  @override
  List<Object?> get props => [streaks];
}

class StreaksError extends StreaksState {
  final String message;

  const StreaksError(this.message);

  @override
  List<Object?> get props => [message];
}
