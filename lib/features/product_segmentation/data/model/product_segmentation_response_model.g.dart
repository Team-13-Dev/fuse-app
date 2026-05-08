// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_segmentation_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductSegmentationResponseModel _$ProductSegmentationResponseModelFromJson(
  Map<String, dynamic> json,
) => ProductSegmentationResponseModel(
  hasResults: json['hasResults'] as bool?,
  lastJobAt: json['lastJobAt'] as String?,
  clusters: json['clusters'] as List<dynamic>?,
  minProductsNeeded: (json['minProductsNeeded'] as num?)?.toInt(),
  productCount: (json['productCount'] as num?)?.toInt(),
  segments: json['segments'] as List<dynamic>?,
);

Map<String, dynamic> _$ProductSegmentationResponseModelToJson(
  ProductSegmentationResponseModel instance,
) => <String, dynamic>{
  'hasResults': instance.hasResults,
  'productCount': instance.productCount,
  'minProductsNeeded': instance.minProductsNeeded,
  'lastJobAt': instance.lastJobAt,
  'segments': instance.segments,
  'clusters': instance.clusters,
};
