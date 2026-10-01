import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_attend/core/router/app_router.dart';
import 'package:qr_attend/core/usecases/usecase.dart';
import 'package:qr_attend/features/auth/domain/entities/user_entity.dart';
import 'package:qr_attend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:qr_attend/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:qr_attend/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:qr_attend/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:qr_attend/features/auth/presentation/bloc/auth_state.dart';

/// Manages the global authentication state of the application.
///
/// This cubit is the **single source of truth** for whether the user is
/// authenticated. On every state change it synchronises the
/// [AppRouter.isAuthenticated] and [AppRouter.userRole] ValueNotifiers
/// so the GoRouter redirect logic reacts immediately.
///
/// ## Lifecycle
/// 1. Created at app startup and provided at the root of the widget tree.
/// 2. [checkAuthStatus] is called once from `main.dart` (or a splash page)
///    to restore the previous session.
/// 3. [signIn] / [signUp] are called from the login/register pages.
/// 4. [signOut] is called from the settings or profile menu.
class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitial());

  // ─── Public API ────────────────────────────────────────────────

  /// Checks whether a user is already signed in (session restore on cold start).
  ///
  /// Called once from the app root. Updates the router notifiers so the
  /// redirect logic can resolve the initial route.
  Future<void> checkAuthStatus() async {
    // Don't emit AuthLoading here — we want the splash to stay on AuthInitial
    // while the check runs (AuthInitial is the "loading" indicator on startup).
    final result = await getCurrentUserUseCase(NoParams());

    result.fold(
      (failure) {
        _syncRouterState(authenticated: false);
        emit(const Unauthenticated());
      },
      (user) {
        if (user != null) {
          _syncRouterState(authenticated: true, role: user.role);
          emit(Authenticated(user));
        } else {
          _syncRouterState(authenticated: false);
          emit(const Unauthenticated());
        }
      },
    );
  }

  /// Signs in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await signInUseCase(
      SignInParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        emit(AuthError(failure.message));
      },
      (user) {
        _syncRouterState(authenticated: true, role: user.role);
        emit(Authenticated(user));
      },
    );
  }

  /// Creates a new account with the given profile information.
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    emit(const AuthLoading());

    final result = await signUpUseCase(
      SignUpParams(
        email: email,
        password: password,
        name: name,
        role: role,
      ),
    );

    result.fold(
      (failure) {
        emit(AuthError(failure.message));
      },
      (user) {
        _syncRouterState(authenticated: true, role: user.role);
        emit(Authenticated(user));
      },
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    emit(const AuthLoading());

    final result = await signOutUseCase(NoParams());

    result.fold(
      (failure) {
        emit(AuthError(failure.message));
      },
      (_) {
        _syncRouterState(authenticated: false);
        emit(const Unauthenticated());
      },
    );
  }

  // ─── Private Helpers ───────────────────────────────────────────

  /// Keeps [AppRouter]'s ValueNotifiers in sync with the cubit state.
  ///
  /// This is the bridge between BLoC state management and GoRouter's
  /// declarative redirect system. Setting `isAuthenticated.value` triggers
  /// the router's `refreshListenable`, which re-evaluates [AppRouter._redirect].
  void _syncRouterState({
    required bool authenticated,
    UserRole? role,
  }) {
    // Set role first so it's available when the redirect fires.
    AppRouter.userRole.value = role?.value;
    // Setting isAuthenticated triggers GoRouter.refreshListenable → redirect.
    AppRouter.isAuthenticated.value = authenticated;
  }
}
