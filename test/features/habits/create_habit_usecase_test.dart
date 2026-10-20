import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:untitled3/core/error/failures.dart';
import 'package:untitled3/features/habits/domain/entities/habit_entity.dart';
import 'package:untitled3/features/habits/domain/repositories/habits_repository.dart';
import 'package:untitled3/features/habits/domain/usecases/create_habit_usecase.dart';

class MockHabitsRepository extends Mock implements HabitsRepository {}

void main() {
  late CreateHabitUseCase useCase;
  late MockHabitsRepository mockRepository;

  setUp(() {
    mockRepository = MockHabitsRepository();
    useCase = CreateHabitUseCase(mockRepository);
  });

  final testHabit = HabitEntity(
    id: 'habit-1',
    userId: 'user-1',
    title: 'Read Books',
    points: 20,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('CreateHabitUseCase validation tests', () {
    test(
      'successfully delegates to repository when inputs are valid',
      () async {
        when(
          () => mockRepository.createHabit(
            userId: 'user-1',
            title: 'Read Books',
            points: 20,
            description: null,
          ),
        ).thenAnswer((_) async => Right(testHabit));

        final result = await useCase(
          const CreateHabitParams(
            userId: 'user-1',
            title: 'Read Books',
            points: 20,
          ),
        );

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should have succeeded'),
          (habit) => expect(habit, equals(testHabit)),
        );
      },
    );

    test(
      'returns ValidationFailure when title is empty or only whitespace',
      () async {
        final result = await useCase(
          const CreateHabitParams(userId: 'user-1', title: '   ', points: 10),
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Habit title cannot be empty');
        }, (_) => fail('Should have returned Left'));
        verifyNever(
          () => mockRepository.createHabit(
            userId: any(named: 'userId'),
            title: any(named: 'title'),
            points: any(named: 'points'),
          ),
        );
      },
    );

    test(
      'returns ValidationFailure when points are below minimum (< 1)',
      () async {
        final result = await useCase(
          const CreateHabitParams(
            userId: 'user-1',
            title: 'Meditation',
            points: 0,
          ),
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Points must be between 1 and 1000');
        }, (_) => fail('Should have returned Left'));
      },
    );

    test(
      'returns ValidationFailure when points exceed maximum (> 1000)',
      () async {
        final result = await useCase(
          const CreateHabitParams(
            userId: 'user-1',
            title: 'Meditation',
            points: 1001,
          ),
        );

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Points must be between 1 and 1000');
        }, (_) => fail('Should have returned Left'));
      },
    );
  });
}
