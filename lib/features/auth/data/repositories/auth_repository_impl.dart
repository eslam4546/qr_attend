import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_attend/core/error/exceptions.dart';
import 'package:qr_attend/core/error/failures.dart';
import 'package:qr_attend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:qr_attend/features/auth/domain/entities/user_entity.dart';
import 'package:qr_attend/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Orchestrates the [AuthRemoteDataSource] and caches the user role
/// in [SharedPreferences] so the router can determine the correct
/// home screen instantly on cold start (before the Firestore round-trip).
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  /// SharedPreferences key for the cached user role.
  static const String _cachedRoleKey = 'CACHED_USER_ROLE';

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  // ─── AuthRepository contract ───────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      await _cacheRole(user.role);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      await _cacheRole(user.role);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await _clearCachedRole();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      if (user != null) {
        await _cacheRole(user.role);
      }
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ─── Role Cache Helpers ────────────────────────────────────────

  /// Persists the role string so [AppRouter] can read it synchronously.
  Future<void> _cacheRole(UserRole role) async {
    await sharedPreferences.setString(_cachedRoleKey, role.value);
  }

  /// Clears the cached role on sign-out.
  Future<void> _clearCachedRole() async {
    await sharedPreferences.remove(_cachedRoleKey);
  }

  /// Reads the cached role, if any.
  ///
  /// This is exposed as a static helper so the DI layer or the router
  /// can access the cached role without going through the full
  /// [getCurrentUser] flow.
  static String? getCachedRole(SharedPreferences prefs) {
    return prefs.getString(_cachedRoleKey);
  }
}
