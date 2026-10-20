import 'package:untitled3/core/utils/date_utils_helper.dart';
import 'package:untitled3/features/habits/domain/entities/completion_entity.dart';
import 'package:untitled3/features/habits/domain/entities/habit_entity.dart';
import 'package:untitled3/features/streaks/domain/entities/streak_info.dart';

class StreakCalculator {
  const StreakCalculator();

  /// Calculates StreakInfo for a habit given its completion records and reference date.
  ///
  /// Streak business rules:
  /// 1. Consecutive calendar days in user's local timezone.
  /// 2. If today is completed, current streak includes today and consecutive completed past days.
  /// 3. If today is NOT completed yet, today preserves the streak accumulated through yesterday
  ///    (since the day is not over yet).
  /// 4. If yesterday was NOT completed and today is NOT completed, the current streak is 0.
  /// 5. Longest streak is the maximum consecutive completed calendar days in history.
  StreakInfo calculate({
    required HabitEntity habit,
    required List<CompletionEntity> completions,
    DateTime? referenceDate,
  }) {
    final refDate = referenceDate ?? DateTime.now();
    final today = DateUtilsHelper.startOfDay(refDate);
    final todayKey = DateUtilsHelper.toDateKey(today);
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayKey = DateUtilsHelper.toDateKey(yesterday);

    // Filter completions to only those where isCompleted is true, indexed by dateKey
    final Set<String> completedDateKeys = completions
        .where((c) => c.isCompleted)
        .map((c) => c.dateKey)
        .toSet();

    // 1. Calculate Current Streak
    int currentStreak = 0;
    bool todayCompleted = completedDateKeys.contains(todayKey);
    bool yesterdayCompleted = completedDateKeys.contains(yesterdayKey);

    DateTime checkDate;
    if (todayCompleted) {
      currentStreak = 1;
      checkDate = yesterday;
      while (completedDateKeys.contains(DateUtilsHelper.toDateKey(checkDate))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else if (yesterdayCompleted) {
      // Today is pending, but streak up to yesterday is active
      currentStreak = 1;
      checkDate = yesterday.subtract(const Duration(days: 1));
      while (completedDateKeys.contains(DateUtilsHelper.toDateKey(checkDate))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else {
      currentStreak = 0;
    }

    // 2. Calculate Longest Streak across all completion records
    int longestStreak = _calculateLongestStreak(completedDateKeys);
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    // 3. Build 7-day visualization (past 6 days + today, sorted chronologically)
    final past7Days = DateUtilsHelper.getPastDays(7, referenceDate: refDate);
    final List<DayCompletionItem> last7DaysList = past7Days.map((d) {
      final key = DateUtilsHelper.toDateKey(d);
      return DayCompletionItem(
        date: d,
        dateKey: key,
        isCompleted: completedDateKeys.contains(key),
      );
    }).toList();

    return StreakInfo(
      habitId: habit.id,
      habitTitle: habit.title,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      last7Days: last7DaysList,
    );
  }

  int _calculateLongestStreak(Set<String> dateKeys) {
    if (dateKeys.isEmpty) return 0;

    // Convert date keys to sorted DateTimes
    final dates =
        dateKeys
            .map((k) {
              try {
                return DateUtilsHelper.parseDateKey(k);
              } catch (_) {
                return null;
              }
            })
            .whereType<DateTime>()
            .toList()
          ..sort((a, b) => a.compareTo(b));

    if (dates.isEmpty) return 0;

    int maxStreak = 1;
    int currentRun = 1;

    for (int i = 1; i < dates.length; i++) {
      final prev = dates[i - 1];
      final curr = dates[i];
      final diffDays = curr.difference(prev).inDays;

      if (diffDays == 1) {
        currentRun++;
        if (currentRun > maxStreak) {
          maxStreak = currentRun;
        }
      } else if (diffDays > 1) {
        currentRun = 1;
      }
      // If diffDays == 0 (duplicate), do nothing
    }

    return maxStreak;
  }
}
