import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/core/usecases/usecase.dart';
import 'package:untitled3/features/authentication/domain/repositories/auth_repository.dart';
import 'package:untitled3/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:untitled3/features/authentication/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SignInAnonymouslyUseCase signInAnonymouslyUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  StreamSubscription? _authSubscription;

  AuthBloc({
    required this.authRepository,
    required this.signInAnonymouslyUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignInAnonymouslyRequested>(_onAuthSignInAnonymouslyRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);

    _authSubscription = authRepository.authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase(const NoParams());
    result.fold((failure) => emit(Unauthenticated()), (user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        // Auto sign in anonymously for friction-free user experience
        add(AuthSignInAnonymouslyRequested());
      }
    });
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthSignInAnonymouslyRequested(
    AuthSignInAnonymouslyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInAnonymouslyUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await authRepository.signOut();
    emit(Unauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
