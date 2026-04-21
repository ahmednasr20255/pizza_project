import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    debugPrint('AuthBloc: Starting login for email: ${event.email}');
    emit(const AuthLoading());

    try {
      final result = await authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      result.fold(
        (failure) {
          debugPrint('AuthBloc: Login failed - ${_getErrorMessage(failure)}');
          emit(AuthError(_getErrorMessage(failure)));
        },
        (user) {
          debugPrint('AuthBloc: Login successful for user: ${user.email}');
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      debugPrint('AuthBloc: Unexpected login error: $e');
      emit(AuthError('Unexpected error during login: $e'));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    debugPrint('AuthBloc: Starting registration for email: ${event.email}');
    emit(const AuthLoading());

    try {
      final result = await authRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.name,
        phoneNumber: event.phoneNumber,
      );

      debugPrint('AuthBloc: Processing registration result...');
      result.fold(
        (failure) {
          debugPrint('AuthBloc: Registration failed - ${_getErrorMessage(failure)}');
          emit(AuthError(_getErrorMessage(failure)));
        },
        (user) {
          debugPrint('AuthBloc: Registration successful for user: ${user.email}, emitting AuthAuthenticated state');
          emit(AuthAuthenticated(user));
        },
      );
      debugPrint('AuthBloc: Registration result processed');
    } catch (e) {
      debugPrint('AuthBloc: Unexpected registration error: $e');
      emit(AuthError('Unexpected error during registration: $e'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await authRepository.signOut();

    result.fold(
      (failure) => emit(AuthError(_getErrorMessage(failure))),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  String _getErrorMessage(Failure failure) {
    if (failure is AuthFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return failure.message;
    }
    return 'An unexpected error occurred';
  }
}
