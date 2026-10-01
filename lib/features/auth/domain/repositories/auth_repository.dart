import 'package:dartz/dartz.dart';
import 'package:qr_attend/core/error/failures.dart';
import 'package:qr_attend/features/auth/domain/entities/user_entity.dart';

/// Contract for the authentication repository.
///
/// The domain layer depends on this interface; the data layer provides
/// the concrete [AuthRepositoryImpl].
abstract class AuthRepository {
  /// Creates a new account and writes the user document to Firestore.
  ///
  /// Returns the created [UserEntity] on success, or an [AuthFailure] /
  /// [ServerFailure] on error.
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });

  /// Signs in with email and password, then fetches the user profile
  /// from Firestore.
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<Either<Failure, void>> signOut();

  /// Returns the currently signed-in user (from Firebase Auth + Firestore),
  /// or `null` wrapped in a [Right] if no one is signed in.
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
