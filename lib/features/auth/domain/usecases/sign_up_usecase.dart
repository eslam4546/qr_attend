import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_attend/core/error/failures.dart';
import 'package:qr_attend/core/usecases/usecase.dart';
import 'package:qr_attend/features/auth/domain/entities/user_entity.dart';
import 'package:qr_attend/features/auth/domain/repositories/auth_repository.dart';

/// Registers a new user with the given credentials and role.
class SignUpUseCase extends UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) {
    return repository.signUp(
      email: params.email,
      password: params.password,
      name: params.name,
      role: params.role,
    );
  }
}

/// Parameters required for [SignUpUseCase].
class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final UserRole role;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}
