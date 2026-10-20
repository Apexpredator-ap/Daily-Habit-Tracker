import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:untitled3/core/error/failures.dart';
import 'package:untitled3/features/habits/domain/entities/habit_entity.dart';
import 'package:untitled3/features/habits/domain/usecases/create_habit_usecase.dart';
import 'package:untitled3/features/habits/presentation/bloc/add_habit_bloc.dart';
import 'package:untitled3/features/habits/presentation/bloc/add_habit_state.dart';

class MockCreateHabitUseCase extends Mock implements CreateHabitUseCase {}

void main() {
  late MockCreateHabitUseCase mockCreateHabitUseCase;
  late AddHabitBloc addHabitBloc;

  setUpAll(() {
    registerFallbackValue(
      const CreateHabitParams(userId: 'user-1', title: 'Exercise', points: 10),
    );
  });

  setUp(() {
    mockCreateHabitUseCase = MockCreateHabitUseCase();
    addHabitBloc = AddHabitBloc(createHabitUseCase: mockCreateHabitUseCase);
  });

  tearDown(() {
    addHabitBloc.close();
  });

  final testHabit = HabitEntity(
    id: 'habit-101',
    userId: 'user-1',
    title: 'Morning Jogging',
    points: 15,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('AddHabitBloc tests', () {
    test('initial state is AddHabitInitial', () {
      expect(addHabitBloc.state, AddHabitInitial());
    });

    blocTest<AddHabitBloc, AddHabitState>(
      'emits [AddHabitSubmitting, AddHabitSuccess] on successful submission',
      build: () {
        when(
          () => mockCreateHabitUseCase(any()),
        ).thenAnswer((_) async => Right(testHabit));
        return addHabitBloc;
      },
      act: (bloc) => bloc.add(
        const AddHabitSubmitted(
          userId: 'user-1',
          title: 'Morning Jogging',
          points: 15,
        ),
      ),
      expect: () => [AddHabitSubmitting(), AddHabitSuccess(testHabit)],
    );

    blocTest<AddHabitBloc, AddHabitState>(
      'emits [AddHabitSubmitting, AddHabitFailure] when usecase returns Failure',
      build: () {
        when(() => mockCreateHabitUseCase(any())).thenAnswer(
          (_) async =>
              const Left(ValidationFailure('Habit title cannot be empty')),
        );
        return addHabitBloc;
      },
      act: (bloc) => bloc.add(
        const AddHabitSubmitted(userId: 'user-1', title: '', points: 10),
      ),
      expect: () => [
        AddHabitSubmitting(),
        const AddHabitFailure('Habit title cannot be empty'),
      ],
    );
  });
}
