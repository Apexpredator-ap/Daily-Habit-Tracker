import 'package:flutter_test/flutter_test.dart';
import 'package:untitled3/features/habits/domain/entities/completion_entity.dart';
import 'package:untitled3/features/habits/domain/entities/habit_entity.dart';
import 'package:untitled3/features/streaks/domain/services/streak_calculator.dart';

void main() {
  late StreakCalculator calculator;
  late HabitEntity testHabit;

  setUp(() {
    calculator = const StreakCalculator();
    final now = DateTime(2026, 10, 19, 10, 0, 0);
    testHabit = HabitEntity(
      id: 'habit-1',
      userId: 'user-1',
      title: 'Drink 2L Water',
      points: 10,
      createdAt: now,
      updatedAt: now,
    );
  });

  group('StreakCalculator tests', () {
    final refDate = DateTime(2026, 10, 19); // Today: 2026-10-19

    test('returns 0 streak when completions list is empty', () {
      final result = calculator.calculate(
        habit: testHabit,
        completions: [],
        referenceDate: refDate,
      );

      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
      expect(result.last7Days.length, 7);
      expect(result.last7Days.every((d) => !d.isCompleted), true);
    });

    test('returns 1 streak when only today is completed', () {
      final completions = [
        CompletionEntity(
          dateKey: '2026-10-19',
          habitId: 'habit-1',
          isCompleted: true,
          pointsEarned: 10,
          completedAt: refDate,
        ),
      ];

      final result = calculator.calculate(
        habit: testHabit,
        completions: completions,
        referenceDate: refDate,
      );

      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
      expect(result.last7Days.last.isCompleted, true);
    });

    test(
      'preserves previous streak when today is not yet completed but yesterday is',
      () {
        final completions = [
          CompletionEntity(
            dateKey: '2026-10-18', // Yesterday
            habitId: 'habit-1',
            isCompleted: true,
            pointsEarned: 10,
            completedAt: refDate.subtract(const Duration(days: 1)),
          ),
          CompletionEntity(
            dateKey: '2026-10-17', // 2 days ago
            habitId: 'habit-1',
            isCompleted: true,
            pointsEarned: 10,
            completedAt: refDate.subtract(const Duration(days: 2)),
          ),
        ];

        final result = calculator.calculate(
          habit: testHabit,
          completions: completions,
          referenceDate: refDate,
        );

        // Streak up to yesterday is 2 days. Because today is not completed yet, the streak is preserved as 2.
        expect(result.currentStreak, 2);
        expect(result.longestStreak, 2);
        expect(result.last7Days.last.isCompleted, false);
      },
    );

    test('current streak advances when today is completed after yesterday', () {
      final completions = [
        CompletionEntity(
          dateKey: '2026-10-19', // Today
          habitId: 'habit-1',
          isCompleted: true,
          pointsEarned: 10,
          completedAt: refDate,
        ),
        CompletionEntity(
          dateKey: '2026-10-18', // Yesterday
          habitId: 'habit-1',
          isCompleted: true,
          pointsEarned: 10,
          completedAt: refDate.subtract(const Duration(days: 1)),
        ),
        CompletionEntity(
          dateKey: '2026-10-17', // 2 days ago
          habitId: 'habit-1',
          isCompleted: true,
          pointsEarned: 10,
          completedAt: refDate.subtract(const Duration(days: 2)),
        ),
      ];

      final result = calculator.calculate(
        habit: testHabit,
        completions: completions,
        referenceDate: refDate,
      );

      expect(result.currentStreak, 3);
      expect(result.longestStreak, 3);
    });

    test(
      'breaks streak if yesterday was missed and today is not completed',
      () {
        final completions = [
          CompletionEntity(
            dateKey: '2026-10-17', // 2 days ago, but 10-18 was missed
            habitId: 'habit-1',
            isCompleted: true,
            pointsEarned: 10,
            completedAt: refDate.subtract(const Duration(days: 2)),
          ),
        ];

        final result = calculator.calculate(
          habit: testHabit,
          completions: completions,
          referenceDate: refDate,
        );

        expect(result.currentStreak, 0);
        expect(result.longestStreak, 1);
      },
    );

    test(
      'correctly computes longest streak even when current streak is broken',
      () {
        // Historical 5-day streak in September, broken, then 2-day streak currently
        final completions = [
          // Historical 5 days: Sep 1 to Sep 5
          for (int i = 1; i <= 5; i++)
            CompletionEntity(
              dateKey: '2026-09-0$i',
              habitId: 'habit-1',
              isCompleted: true,
              pointsEarned: 10,
              completedAt: DateTime(2026, 9, i),
            ),
          // Current 2 days: Oct 18, 19
          CompletionEntity(
            dateKey: '2026-10-18',
            habitId: 'habit-1',
            isCompleted: true,
            pointsEarned: 10,
            completedAt: DateTime(2026, 10, 18),
          ),
          CompletionEntity(
            dateKey: '2026-10-19',
            habitId: 'habit-1',
            isCompleted: true,
            pointsEarned: 10,
            completedAt: DateTime(2026, 10, 19),
          ),
        ];

        final result = calculator.calculate(
          habit: testHabit,
          completions: completions,
          referenceDate: refDate,
        );

        expect(result.currentStreak, 2);
        expect(result.longestStreak, 5);
      },
    );

    test('handles leap year date transition properly', () {
      // 2024 was leap year: Feb 28 -> Feb 29 -> Mar 1
      final leapRef = DateTime(2024, 3, 1);
      final completions = [
        CompletionEntity(
          dateKey: '2024-02-28',
          habitId: 'habit-1',
          isCompleted: true,
          pointsEarned: 10,
          completedAt: DateTime(2024, 2, 28),
        ),
        CompletionEntity(
          dateKey: '2024-02-29',
          habitId: 'habit-1',
          isCompleted: true,
          pointsEarned: 10,
          completedAt: DateTime(2024, 2, 29),
        ),
        CompletionEntity(
          dateKey: '2024-03-01',
          habitId: 'habit-1',
          isCompleted: true,
          pointsEarned: 10,
          completedAt: DateTime(2024, 3, 1),
        ),
      ];

      final result = calculator.calculate(
        habit: testHabit,
        completions: completions,
        referenceDate: leapRef,
      );

      expect(result.currentStreak, 3);
      expect(result.longestStreak, 3);
    });

    test(
      'handles duplicate completion records gracefully without overcounting',
      () {
        final completions = [
          CompletionEntity(
            dateKey: '2026-10-19',
            habitId: 'habit-1',
            isCompleted: true,
            pointsEarned: 10,
            completedAt: refDate,
          ),
          CompletionEntity(
            dateKey: '2026-10-19', // Duplicate entry for same day
            habitId: 'habit-1',
            isCompleted: true,
            pointsEarned: 10,
            completedAt: refDate,
          ),
        ];

        final result = calculator.calculate(
          habit: testHabit,
          completions: completions,
          referenceDate: refDate,
        );

        expect(result.currentStreak, 1);
        expect(result.longestStreak, 1);
      },
    );
  });
}
