import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_attend/core/error/failures.dart';

/// Base class for all use cases in the application.
/// [ReturnType] is the return type on success.
/// [Params] is the input parameter type.
abstract class UseCase<ReturnType, Params> {
  Future<Either<Failure, ReturnType>> call(Params params);
}

/// Use this when a use case doesn't require any parameters.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
