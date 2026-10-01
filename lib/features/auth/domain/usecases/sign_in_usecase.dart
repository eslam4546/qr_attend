import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_attend/core/error/failures.dart';
import 'package:qr_attend/core/usecases/usecase.dart';
import 'package:qr_attend/features/auth/domain/entities/user_entity.dart';
import 'package:qr_attend/features/auth/domain/repositories/auth_repository.dart';

/// Signs in an existing user with email and password.
class SignInUseCase extends UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) {
    return repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters required for [SignInUseCase].
class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
