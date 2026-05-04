import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/features/product/data/model/product_response_model.dart';

part 'add_product_state.freezed.dart';

@freezed
class AddProductState with _$AddProductState {
  const factory AddProductState.initial() = _Initial;
  const factory AddProductState.loading() = Loading;
  const factory AddProductState.success(ProductResponseModel data) = Success;
  const factory AddProductState.error(ErrorHandler error) = Error;
}
