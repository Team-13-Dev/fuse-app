import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_segmentation_response_model.g.dart';

@JsonSerializable()
class ProductSegmentationResponseModel {
  final bool? hasResults;
  final int? productCount;
  final int? minProductsNeeded;
  final String? lastJobAt;
  final List? segments;
  final List? clusters;

  ProductSegmentationResponseModel({
    this.hasResults,
    this.lastJobAt,
    this.clusters,
    this.minProductsNeeded,
    this.productCount,
    this.segments,
  });

  factory ProductSegmentationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$ProductSegmentationResponseModelFromJson(json);
}
