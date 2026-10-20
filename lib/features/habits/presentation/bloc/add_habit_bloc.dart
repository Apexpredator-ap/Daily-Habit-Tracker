import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/features/habits/domain/usecases/create_habit_usecase.dart';
import 'package:untitled3/features/habits/presentation/bloc/add_habit_state.dart';

class AddHabitBloc extends Bloc<AddHabitEvent, AddHabitState> {
  final CreateHabitUseCase createHabitUseCase;

  AddHabitBloc({required this.createHabitUseCase}) : super(AddHabitInitial()) {
    on<AddHabitSubmitted>(_onAddHabitSubmitted);
    on<AddHabitReset>((event, emit) => emit(AddHabitInitial()));
  }

  Future<void> _onAddHabitSubmitted(
    AddHabitSubmitted event,
    Emitter<AddHabitState> emit,
  ) async {
    // Prevent duplicate submission while already submitting
    if (state is AddHabitSubmitting) return;

    emit(AddHabitSubmitting());

    final result = await createHabitUseCase(
      CreateHabitParams(
        userId: event.userId,
        title: event.title,
        points: event.points,
        description: event.description,
      ),
    );

    result.fold(
      (failure) => emit(AddHabitFailure(failure.message)),
      (habit) => emit(AddHabitSuccess(habit)),
    );
  }
}
