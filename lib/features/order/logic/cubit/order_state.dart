import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/features/order/data/model/add_order_response_model.dart';
import 'package:fuse_system/features/order/data/model/order_response_model.dart';

part 'order_state.freezed.dart';

@freezed
class OrderState with _$OrderState {
  const factory OrderState.initial() = _Initial;
  const factory OrderState.loading() = Loading;
  const factory OrderState.success(List<OrderResponseModel> orders) = Success;
  const factory OrderState.successCreate(AddOrderResponseModel order) =
      SuccessCreate;
  const factory OrderState.successDelete() = SuccessDelete;
  const factory OrderState.error(ErrorHandler error) = Error;
}
