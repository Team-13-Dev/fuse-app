import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';

part 'api_results.freezed.dart';

@freezed
sealed class ApiResults<T> with _$ApiResults<T> {
  const factory ApiResults.success(T data) = Success<T>;
  const factory ApiResults.failure(ErrorHandler errorHandler) = Failure<T>;
}
