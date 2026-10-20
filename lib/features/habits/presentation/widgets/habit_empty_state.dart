import 'package:flutter/material.dart';
import 'package:untitled3/core/theme/app_theme.dart';

class HabitEmptyState extends StatelessWidget {
  final VoidCallback onAddHabit;

  const HabitEmptyState({super.key, required this.onAddHabit});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No Habits For Today',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Build routines that stick. Start your journey by creating your first daily habit.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: onAddHabit,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add First Habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
