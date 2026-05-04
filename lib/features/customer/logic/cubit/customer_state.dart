import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/features/customer/data/model/customer_response_model.dart';

part 'customer_state.freezed.dart';

@freezed
class CustomerState with _$CustomerState {
  const factory CustomerState.initial() = _Initial;
  const factory CustomerState.loading() = Loading;
  const factory CustomerState.success(List<CustomerResponseModel> customers) =
      Success;
  const factory CustomerState.successCreate(CustomerResponseModel customer) =
      SuccessCreate;
  const factory CustomerState.successDelete() = SuccessDelete;
  const factory CustomerState.error(ErrorHandler error) = Error;
}
