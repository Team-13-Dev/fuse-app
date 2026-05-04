import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';

part 'signout_state.freezed.dart';

@freezed
class SignoutState with _$SignoutState {
  const factory SignoutState.initial() = _Initial;
  const factory SignoutState.loading() = Loading;
  const factory SignoutState.success() = Success;
  const factory SignoutState.error(ErrorHandler error) = Error;
}
