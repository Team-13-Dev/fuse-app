import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/features/product/data/model/product_response_model.dart';

part 'product_state.freezed.dart';

@freezed
class ProductState with _$ProductState {
  const factory ProductState.initial() = _Initial;
  const factory ProductState.loading() = Loading;
  const factory ProductState.success(List<ProductResponseModel> data) =
      Success; // non-nullable list
  const factory ProductState.error(ErrorHandler error) = Error;
}
