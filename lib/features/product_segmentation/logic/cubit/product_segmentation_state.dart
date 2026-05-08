import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/features/product_segmentation/data/model/product_segmentation_response_model.dart';

part 'product_segmentation_state.freezed.dart';

@freezed
class ProductSegmentationState with _$ProductSegmentationState {
  const factory ProductSegmentationState.initial() = _Initial;
  const factory ProductSegmentationState.loading() = Loading;
  const factory ProductSegmentationState.success(
    ProductSegmentationResponseModel data,
  ) = Success;
  const factory ProductSegmentationState.error(ErrorHandler error) = Error;
}
