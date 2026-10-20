import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/theme/app_theme.dart';
import 'package:untitled3/core/utils/date_utils_helper.dart';
import 'package:untitled3/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:untitled3/features/authentication/presentation/bloc/auth_state.dart';
import 'package:untitled3/features/habits/presentation/bloc/today_habits_bloc.dart';
import 'package:untitled3/features/habits/presentation/bloc/today_habits_state.dart';
import 'package:untitled3/features/habits/presentation/widgets/habit_empty_state.dart';
import 'package:untitled3/features/habits/presentation/widgets/habit_header_card.dart';
import 'package:untitled3/features/habits/presentation/widgets/habit_list_item_card.dart';

class TodayHabitsPage extends StatefulWidget {
  const TodayHabitsPage({super.key});

  @override
  State<TodayHabitsPage> createState() => _TodayHabitsPageState();
}

class _TodayHabitsPageState extends State<TodayHabitsPage>
    with WidgetsBindingObserver {
  late String _currentDateKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentDateKey = DateUtilsHelper.todayDateKey();
    _startWatchingHabits();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check if date changed while app was in background
      final todayKey = DateUtilsHelper.todayDateKey();
      if (todayKey != _currentDateKey) {
        setState(() {
          _currentDateKey = todayKey;
        });
        _startWatchingHabits();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startWatchingHabits() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<TodayHabitsBloc>().add(
        WatchTodayHabitsStarted(
          userId: authState.user.id,
          dateKey: _currentDateKey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is Authenticated) {
          context.read<TodayHabitsBloc>().add(
            WatchTodayHabitsStarted(
              userId: authState.user.id,
              dateKey: _currentDateKey,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HabitFlow'),
          actions: [
            IconButton(
              icon: const Icon(Icons.local_fire_department_rounded),
              tooltip: 'Streaks',
              color: AppColors.streakActive,
              onPressed: () => context.push('/streaks'),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: _startWatchingHabits,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/add-habit'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Habit'),
        ),
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthLoading || authState is AuthInitial) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                );
              }

              if (authState is AuthError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Authentication Notice:\n${authState.message}\n\nPlease ensure Anonymous Sign-In is enabled in your Firebase Console under Authentication > Sign-in method.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              AuthSignInAnonymouslyRequested(),
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry Connection'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return BlocBuilder<TodayHabitsBloc, TodayHabitsState>(
                builder: (context, state) {
                  if (state is TodayHabitsLoading ||
                      state is TodayHabitsInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    );
                  }

                  if (state is TodayHabitsError) {
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
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton(
                              onPressed: _startWatchingHabits,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is TodayHabitsLoaded) {
                    if (state.isEmpty) {
                      return HabitEmptyState(
                        onAddHabit: () => context.push('/add-habit'),
                      );
                    }

                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          sliver: SliverToBoxAdapter(
                            child: HabitHeaderCard(
                              dateText: DateUtilsHelper.formatReadable(
                                DateTime.now(),
                              ),
                              earnedPoints: state.totalPointsEarnedToday,
                              completedCount: state.completedHabitsCount,
                              totalCount: state.totalHabitsCount,
                              progress: state.completionPercentage,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              child: Text(
                                'TODAY\'S HABITS (${state.totalHabitsCount})',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.xxl * 2, // Space for FAB
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = state.habits[index];
                              final isPending = state.pendingToggleHabitIds
                                  .contains(item.habit.id);

                              return HabitListItemCard(
                                item: item,
                                isPending: isPending,
                                onToggle: (newStatus) {
                                  context.read<TodayHabitsBloc>().add(
                                    ToggleHabitRequested(
                                      habitId: item.habit.id,
                                      isCompleted: newStatus,
                                      points: item.habit.points,
                                    ),
                                  );
                                },
                                onArchive: () {
                                  context.read<TodayHabitsBloc>().add(
                                    ArchiveHabitRequested(item.habit.id),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${item.habit.title} archived',
                                      ),
                                      backgroundColor:
                                          AppColors.surfaceElevated,
                                    ),
                                  );
                                },
                              );
                            }, childCount: state.habits.length),
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
