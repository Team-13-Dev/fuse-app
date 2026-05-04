import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';

part 'signup_state.freezed.dart';

@freezed
class SignupState<T> with _$SignupState<T> {
  const factory SignupState.initial() = _Initial;
  const factory SignupState.loading() = Loading;
  const factory SignupState.success(T data) = Success<T>;
  const factory SignupState.error(ErrorHandler errorHandler) = Error;
}
