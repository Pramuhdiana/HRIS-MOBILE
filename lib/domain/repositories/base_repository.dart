import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Base Repository interface
/// All repositories should implement this for consistency
abstract class BaseRepository {
  // Common repository methods can be added here
}

/// Result type for repository methods
// ignore: unintended_html_in_doc_comment
/// Either<Failure, T> where T is the success type
typedef Result<T> = Either<Failure, T>;

/// Use this for async repository methods
typedef FutureResult<T> = Future<Result<T>>;
