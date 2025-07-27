import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_stored_token_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final CreateUserUseCase createUserUseCase;
  final LogoutUseCase logoutUseCase;
  final GetStoredTokenUseCase getStoredTokenUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.createUserUseCase,
    required this.logoutUseCase,
    required this.getStoredTokenUseCase,
  }) : super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthCreateUserRequested>(_onCreateUserRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Login requested for username: ${event.username}');
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      print('AuthBloc: Calling loginUseCase...');
      final result = await loginUseCase(
        username: event.username,
        password: event.password,
      );

      print('AuthBloc: Login successful, token: ${result.token}');
      print('AuthBloc: User data: ${result.user}');

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
          token: result.token,
          message: 'Login successful',
        ),
      );
    } catch (e) {
      print('AuthBloc: Login failed with error: $e');
      emit(state.copyWith(status: AuthStatus.error, message: e.toString()));
    }
  }

  Future<void> _onCreateUserRequested(
    AuthCreateUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await createUserUseCase(
        firstName: event.firstName,
        lastName: event.lastName,
        username: event.username,
        email: event.email,
        password: event.password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          message: 'Account created successfully! Please login.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await logoutUseCase();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          token: null,
          message: 'Logged out successfully',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, message: e.toString()));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final token = await getStoredTokenUseCase();

      if (token != null && token.isNotEmpty) {
        emit(state.copyWith(status: AuthStatus.authenticated, token: token));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          message: e.toString(),
        ),
      );
    }
  }
}
