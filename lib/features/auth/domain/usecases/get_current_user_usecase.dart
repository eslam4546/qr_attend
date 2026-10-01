import 'package:dartz/dartz.dart';
import 'package:qr_attend/core/error/failures.dart';
import 'package:qr_attend/core/usecases/usecase.dart';
import 'package:qr_attend/features/auth/domain/entities/user_entity.dart';
import 'package:qr_attend/features/auth/domain/repositories/auth_repository.dart';

/// Retrieves the currently signed-in user, or `null` if no one is signed in.
///
/// This is called on app startup to determine whether to show the login
/// screen or the appropriate home screen (professor / student).
class GetCurrentUserUseCase extends UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
