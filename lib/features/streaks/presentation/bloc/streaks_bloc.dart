import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/features/streaks/domain/usecases/get_habit_streaks_usecase.dart';
import 'package:untitled3/features/streaks/presentation/bloc/streaks_state.dart';

class StreaksBloc extends Bloc<StreaksEvent, StreaksState> {
  final GetHabitStreaksUseCase getHabitStreaksUseCase;

  StreaksBloc({required this.getHabitStreaksUseCase})
    : super(StreaksInitial()) {
    on<LoadStreaksRequested>(_onLoadStreaksRequested);
  }

  Future<void> _onLoadStreaksRequested(
    LoadStreaksRequested event,
    Emitter<StreaksState> emit,
  ) async {
    emit(StreaksLoading());

    final result = await getHabitStreaksUseCase(
      GetHabitStreaksParams(
        userId: event.userId,
        referenceDate: event.referenceDate,
      ),
    );

    result.fold(
      (failure) => emit(StreaksError(failure.message)),
      (streaks) => emit(StreaksLoaded(streaks)),
    );
  }
}
