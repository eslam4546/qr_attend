import 'package:dartz/dartz.dart';
import 'package:qr_attend/core/error/failures.dart';
import 'package:qr_attend/core/usecases/usecase.dart';
import 'package:qr_attend/features/auth/domain/repositories/auth_repository.dart';

/// Signs out the currently authenticated user.
class SignOutUseCase extends UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}
