import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/theme/app_theme.dart';
import 'package:untitled3/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:untitled3/features/authentication/presentation/bloc/auth_state.dart';
import 'package:untitled3/features/streaks/presentation/bloc/streaks_bloc.dart';
import 'package:untitled3/features/streaks/presentation/bloc/streaks_state.dart';
import 'package:untitled3/features/streaks/presentation/widgets/habit_streak_card.dart';

class HabitStreaksPage extends StatefulWidget {
  const HabitStreaksPage({super.key});

  @override
  State<HabitStreaksPage> createState() => _HabitStreaksPageState();
}

class _HabitStreaksPageState extends State<HabitStreaksPage> {
  @override
  void initState() {
    super.initState();
    _loadStreaks();
  }

  void _loadStreaks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<StreaksBloc>().add(
        LoadStreaksRequested(userId: authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Streaks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Streaks',
            onPressed: _loadStreaks,
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<StreaksBloc, StreaksState>(
          builder: (context, state) {
            if (state is StreaksLoading || state is StreaksInitial) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is StreaksError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _loadStreaks,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is StreaksLoaded) {
              if (state.streaks.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_fire_department_outlined,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'No Active Streaks',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Create and complete daily habits to build and track your streaks over time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ElevatedButton(
                          onPressed: () => context.push('/add-habit'),
                          child: const Text('Create a Habit'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.streaks.length,
                itemBuilder: (context, index) {
                  return HabitStreakCard(streakInfo: state.streaks[index]);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
