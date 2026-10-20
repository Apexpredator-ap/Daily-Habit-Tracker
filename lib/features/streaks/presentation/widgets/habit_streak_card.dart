import 'package:flutter/material.dart';
import 'package:untitled3/core/theme/app_theme.dart';
import 'package:untitled3/core/utils/date_utils_helper.dart';
import 'package:untitled3/features/streaks/domain/entities/streak_info.dart';

class HabitStreakCard extends StatelessWidget {
  final StreakInfo streakInfo;

  const HabitStreakCard({super.key, required this.streakInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(31),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Streaks Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  streakInfo.habitTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Current Streak Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.streakGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${streakInfo.currentStreak} d',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Best Streak: ${streakInfo.longestStreak} days',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: AppSpacing.md),
          // 7-day completion visualization
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: streakInfo.last7Days.map((dayItem) {
              final dayLabel = DateUtilsHelper.formatShortDay(dayItem.date);
              final isToday = dayItem.dateKey == DateUtilsHelper.todayDateKey();

              return Column(
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      color: isToday ? AppColors.primary : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: dayItem.isCompleted
                          ? AppColors.primary
                          : AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday
                            ? AppColors.primary
                            : (dayItem.isCompleted
                                  ? AppColors.primary
                                  : AppColors.cardBorder),
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: dayItem.isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : Text(
                              '${dayItem.date.day}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
