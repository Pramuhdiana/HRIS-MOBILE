// ignore_for_file: avoid_types_as_parameter_names

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Base UseCase interface
/// All use cases should implement this
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// UseCase without parameters
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Base class for use case parameters
abstract class UseCaseParams {
  const UseCaseParams();
}

/// Empty parameters for use cases that don't need parameters
class NoParams extends UseCaseParams {
  const NoParams();
}
