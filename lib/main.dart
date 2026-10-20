import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled3/core/di/injection_container.dart' as di;
import 'package:untitled3/core/router/app_router.dart';
import 'package:untitled3/core/theme/app_theme.dart';
import 'package:untitled3/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:untitled3/features/authentication/presentation/bloc/auth_state.dart';
import 'package:untitled3/features/habits/presentation/bloc/add_habit_bloc.dart';
import 'package:untitled3/features/habits/presentation/bloc/today_habits_bloc.dart';
import 'package:untitled3/features/streaks/presentation/bloc/streaks_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initializing Firebase safely.
  // In environments where google-services.json / firebase_options.dart is pending,
  // we catch initialization error to allow graceful diagnostics and UI verification.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization notice: $e');
    }
  }

  try {
    await di.initDependencies();
  } catch (e) {
    if (kDebugMode) {
      print('Dependency injection notice: $e');
    }
  }

  runApp(const HabitFlowApp());
}

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<TodayHabitsBloc>(create: (_) => di.sl<TodayHabitsBloc>()),
        BlocProvider<AddHabitBloc>(create: (_) => di.sl<AddHabitBloc>()),
        BlocProvider<StreaksBloc>(create: (_) => di.sl<StreaksBloc>()),
      ],
      child: MaterialApp.router(
        title: 'HabitFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
