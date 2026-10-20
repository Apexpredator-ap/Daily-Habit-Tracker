import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/features/habits/presentation/pages/add_habit_page.dart';
import 'package:untitled3/features/habits/presentation/pages/today_habits_page.dart';
import 'package:untitled3/features/streaks/presentation/pages/habit_streaks_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'today_habits',
        builder: (BuildContext context, GoRouterState state) {
          return const TodayHabitsPage();
        },
      ),
      GoRoute(
        path: '/add-habit',
        name: 'add_habit',
        builder: (BuildContext context, GoRouterState state) {
          return const AddHabitPage();
        },
      ),
      GoRoute(
        path: '/streaks',
        name: 'streaks',
        builder: (BuildContext context, GoRouterState state) {
          return const HabitStreaksPage();
        },
      ),
    ],
  );
}
