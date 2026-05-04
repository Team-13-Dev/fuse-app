import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/features/business_switch/data/model/business_switch_response_model.dart';
import 'package:fuse_system/features/login/data/model/login_response_model.dart';

part 'business_switch_state.freezed.dart';

@freezed
class BusinessSwitchState with _$BusinessSwitchState {
  const factory BusinessSwitchState.initial() = _Initial;
  const factory BusinessSwitchState.loading() = Loading;
  const factory BusinessSwitchState.success(
    BusinessSwitchResponseModel businessSwitch,
  ) = Success;
  const factory BusinessSwitchState.error(ErrorHandler error) = Error;
}
