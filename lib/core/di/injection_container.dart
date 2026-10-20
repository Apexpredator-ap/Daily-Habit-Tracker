import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled3/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:untitled3/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:untitled3/features/authentication/domain/repositories/auth_repository.dart';
import 'package:untitled3/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:untitled3/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:untitled3/features/habits/data/datasources/habits_remote_data_source.dart';
import 'package:untitled3/features/habits/data/repositories/habits_repository_impl.dart';
import 'package:untitled3/features/habits/domain/repositories/habits_repository.dart';
import 'package:untitled3/features/habits/domain/usecases/create_habit_usecase.dart';
import 'package:untitled3/features/habits/domain/usecases/toggle_habit_completion_usecase.dart';
import 'package:untitled3/features/habits/domain/usecases/watch_today_habits_usecase.dart';
import 'package:untitled3/features/habits/presentation/bloc/add_habit_bloc.dart';
import 'package:untitled3/features/habits/presentation/bloc/today_habits_bloc.dart';
import 'package:untitled3/features/streaks/domain/services/streak_calculator.dart';
import 'package:untitled3/features/streaks/domain/usecases/get_habit_streaks_usecase.dart';
import 'package:untitled3/features/streaks/presentation/bloc/streaks_bloc.dart';
import 'package:uuid/uuid.dart';

final sl = GetIt.instance;

Future<void> initDependencies({
  FirebaseAuth? firebaseAuth,
  FirebaseFirestore? firestore,
}) async {
  // 1. External
  sl.registerLazySingleton<FirebaseAuth>(
    () => firebaseAuth ?? FirebaseAuth.instance,
  );
  sl.registerLazySingleton<FirebaseFirestore>(
    () => firestore ?? FirebaseFirestore.instance,
  );
  sl.registerLazySingleton<Uuid>(() => const Uuid());
  sl.registerLazySingleton<StreakCalculator>(() => const StreakCalculator());

  // 2. Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSource(sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton<HabitsRemoteDataSource>(
    () => FirestoreHabitsRemoteDataSource(sl<FirebaseFirestore>()),
  );

  // 3. Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<HabitsRepository>(
    () => HabitsRepositoryImpl(
      remoteDataSource: sl<HabitsRemoteDataSource>(),
      streakCalculator: sl<StreakCalculator>(),
      uuid: sl<Uuid>(),
    ),
  );

  // 4. Use Cases
  sl.registerLazySingleton<SignInAnonymouslyUseCase>(
    () => SignInAnonymouslyUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<WatchTodayHabitsUseCase>(
    () => WatchTodayHabitsUseCase(sl<HabitsRepository>()),
  );
  sl.registerLazySingleton<CreateHabitUseCase>(
    () => CreateHabitUseCase(sl<HabitsRepository>()),
  );
  sl.registerLazySingleton<ToggleHabitCompletionUseCase>(
    () => ToggleHabitCompletionUseCase(sl<HabitsRepository>()),
  );
  sl.registerLazySingleton<GetHabitStreaksUseCase>(
    () => GetHabitStreaksUseCase(sl<HabitsRepository>()),
  );

  // 5. BLoCs / Cubits (Factory for transient lifecycle)
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: sl<AuthRepository>(),
      signInAnonymouslyUseCase: sl<SignInAnonymouslyUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );

  sl.registerFactory<TodayHabitsBloc>(
    () => TodayHabitsBloc(
      watchTodayHabitsUseCase: sl<WatchTodayHabitsUseCase>(),
      toggleHabitCompletionUseCase: sl<ToggleHabitCompletionUseCase>(),
      habitsRepository: sl<HabitsRepository>(),
    ),
  );

  sl.registerFactory<AddHabitBloc>(
    () => AddHabitBloc(createHabitUseCase: sl<CreateHabitUseCase>()),
  );

  sl.registerFactory<StreaksBloc>(
    () => StreaksBloc(getHabitStreaksUseCase: sl<GetHabitStreaksUseCase>()),
  );
}
