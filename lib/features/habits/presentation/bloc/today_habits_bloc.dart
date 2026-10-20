import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/features/habits/domain/entities/completion_entity.dart';
import 'package:untitled3/features/habits/domain/repositories/habits_repository.dart';
import 'package:untitled3/features/habits/domain/usecases/toggle_habit_completion_usecase.dart';
import 'package:untitled3/features/habits/domain/usecases/watch_today_habits_usecase.dart';
import 'package:untitled3/features/habits/presentation/bloc/today_habits_state.dart';

class TodayHabitsBloc extends Bloc<TodayHabitsEvent, TodayHabitsState> {
  final WatchTodayHabitsUseCase watchTodayHabitsUseCase;
  final ToggleHabitCompletionUseCase toggleHabitCompletionUseCase;
  final HabitsRepository habitsRepository;

  StreamSubscription? _habitsSubscription;
  String? _currentUserId;
  String? _currentDateKey;

  TodayHabitsBloc({
    required this.watchTodayHabitsUseCase,
    required this.toggleHabitCompletionUseCase,
    required this.habitsRepository,
  }) : super(TodayHabitsInitial()) {
    on<WatchTodayHabitsStarted>(_onWatchTodayHabitsStarted);
    on<HabitsUpdated>(_onHabitsUpdated);
    on<HabitsErrorReceived>(_onHabitsErrorReceived);
    on<ToggleHabitRequested>(_onToggleHabitRequested);
    on<ArchiveHabitRequested>(_onArchiveHabitRequested);
  }

  Future<void> _onWatchTodayHabitsStarted(
    WatchTodayHabitsStarted event,
    Emitter<TodayHabitsState> emit,
  ) async {
    _currentUserId = event.userId;
    _currentDateKey = event.dateKey;

    emit(TodayHabitsLoading());
    await _habitsSubscription?.cancel();

    _habitsSubscription =
        watchTodayHabitsUseCase(
          WatchTodayHabitsParams(userId: event.userId, dateKey: event.dateKey),
        ).listen(
          (result) {
            result.fold(
              (failure) => add(HabitsErrorReceived(failure.message)),
              (habits) => add(HabitsUpdated(habits)),
            );
          },
          onError: (err) {
            add(HabitsErrorReceived(err.toString()));
          },
        );
  }

  void _onHabitsUpdated(HabitsUpdated event, Emitter<TodayHabitsState> emit) {
    final currentState = state;
    final Set<String> pending = currentState is TodayHabitsLoaded
        ? currentState.pendingToggleHabitIds
        : <String>{};

    emit(
      TodayHabitsLoaded(
        habits: event.habits,
        dateKey: _currentDateKey ?? '',
        pendingToggleHabitIds: pending,
      ),
    );
  }

  void _onHabitsErrorReceived(
    HabitsErrorReceived event,
    Emitter<TodayHabitsState> emit,
  ) {
    emit(TodayHabitsError(event.message));
  }

  Future<void> _onToggleHabitRequested(
    ToggleHabitRequested event,
    Emitter<TodayHabitsState> emit,
  ) async {
    if (_currentUserId == null || _currentDateKey == null) return;
    if (state is! TodayHabitsLoaded) return;

    final currentState = state as TodayHabitsLoaded;

    // Prevent duplicate rapid-tap submissions for the same habit
    if (currentState.pendingToggleHabitIds.contains(event.habitId)) {
      return;
    }

    // Add to pending toggles
    final updatedPending = Set<String>.from(currentState.pendingToggleHabitIds)
      ..add(event.habitId);

    // Optimistically toggle completion in state for instant UI reaction
    final updatedHabits = currentState.habits.map((item) {
      if (item.habit.id == event.habitId) {
        return item.copyWith(
          todayCompletion: event.isCompleted
              ? CompletionEntity(
                  dateKey: _currentDateKey!,
                  habitId: event.habitId,
                  isCompleted: true,
                  pointsEarned: event.points,
                  completedAt: DateTime.now(),
                )
              : null,
        );
      }
      return item;
    }).toList();

    emit(
      currentState.copyWith(
        habits: updatedHabits,
        pendingToggleHabitIds: updatedPending,
      ),
    );

    final result = await toggleHabitCompletionUseCase(
      ToggleHabitCompletionParams(
        userId: _currentUserId!,
        habitId: event.habitId,
        dateKey: _currentDateKey!,
        isCompleted: event.isCompleted,
        points: event.points,
      ),
    );

    // Remove from pending
    if (state is TodayHabitsLoaded) {
      final latestState = state as TodayHabitsLoaded;
      final remainingPending = Set<String>.from(
        latestState.pendingToggleHabitIds,
      )..remove(event.habitId);

      result.fold(
        (failure) {
          // If failed, revert optimistic update
          final revertedHabits = latestState.habits.map((item) {
            if (item.habit.id == event.habitId) {
              return item.copyWith(
                todayCompletion: !event.isCompleted
                    ? CompletionEntity(
                        dateKey: _currentDateKey!,
                        habitId: event.habitId,
                        isCompleted: true,
                        pointsEarned: event.points,
                        completedAt: DateTime.now(),
                      )
                    : null,
              );
            }
            return item;
          }).toList();

          emit(
            latestState.copyWith(
              habits: revertedHabits,
              pendingToggleHabitIds: remainingPending,
            ),
          );
        },
        (completion) {
          emit(latestState.copyWith(pendingToggleHabitIds: remainingPending));
        },
      );
    }
  }

  Future<void> _onArchiveHabitRequested(
    ArchiveHabitRequested event,
    Emitter<TodayHabitsState> emit,
  ) async {
    if (_currentUserId == null) return;
    await habitsRepository.archiveHabit(
      userId: _currentUserId!,
      habitId: event.habitId,
    );
  }

  @override
  Future<void> close() {
    _habitsSubscription?.cancel();
    return super.close();
  }
}
