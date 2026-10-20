import 'package:flutter/material.dart';
import 'package:untitled3/core/theme/app_theme.dart';
import 'package:untitled3/features/habits/domain/entities/habit_with_today_status.dart';

class HabitListItemCard extends StatelessWidget {
  final HabitWithTodayStatus item;
  final bool isPending;
  final ValueChanged<bool> onToggle;
  final VoidCallback onArchive;

  const HabitListItemCard({
    super.key,
    required this.item,
    required this.isPending,
    required this.onToggle,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = item.isCompletedToday;

    return Dismissible(
      key: Key('habit_${item.habit.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(51),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: const Icon(Icons.archive_outlined, color: AppColors.error),
      ),
      onDismissed: (_) => onArchive(),
      child: InkWell(
        onTap: isPending ? null : () => onToggle(!isDone),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDone ? AppColors.primary.withAlpha(20) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isDone
                  ? AppColors.primary.withAlpha(89)
                  : AppColors.cardBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Checkmark indicator circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone ? AppColors.primary : AppColors.textMuted,
                    width: 2,
                  ),
                ),
                child: isPending
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : isDone
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.habit.title,
                      style: TextStyle(
                        color: isDone
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (item.habit.description != null &&
                        item.habit.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.habit.description!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Points Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.primary.withAlpha(51)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '+${item.habit.points} pts',
                  style: TextStyle(
                    color: isDone ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
