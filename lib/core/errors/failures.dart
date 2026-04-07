/// Base Failure class for error handling
abstract class Failure {
  final String message;
  const Failure(this.message);
  
  @override
  String toString() => message;
}

/// Server Failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Authentication Failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Unauthorized Failure
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

/// Not Found Failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Permission Failure
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Multi-Company related failures
class CompanyNotFoundFailure extends Failure {
  const CompanyNotFoundFailure(super.message);
}

class CompanyAccessDeniedFailure extends Failure {
  const CompanyAccessDeniedFailure(super.message);
}