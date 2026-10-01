import 'package:equatable/equatable.dart';
import 'package:qr_attend/features/auth/domain/entities/user_entity.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — auth status has not been checked yet.
///
/// The app shows a loading/splash indicator while [AuthCubit.checkAuthStatus]
/// runs on startup.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A sign-in, sign-up, or sign-out operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The user is authenticated and their profile has been loaded.
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// No user is signed in.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// An authentication operation failed.
///
/// The [message] should be user-friendly (it comes from
/// [AuthRemoteDataSource._mapAuthErrorCode] via the failure chain).
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
