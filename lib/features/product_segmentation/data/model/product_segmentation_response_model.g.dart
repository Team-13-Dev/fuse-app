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
  clusters: (json['clusters'] as List<dynamic>?)
      ?.map((e) => Cluster.fromJson(e as Map<String, dynamic>))
      .toList(),
  minProductsNeeded: (json['minProductsNeeded'] as num?)?.toInt(),
  productCount: (json['productCount'] as num?)?.toInt(),
  segments: (json['segments'] as List<dynamic>?)
      ?.map((e) => Segments.fromJson(e as Map<String, dynamic>))
      .toList(),
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

Segments _$SegmentsFromJson(Map<String, dynamic> json) => Segments(
  productId: json['productId'] as String?,
  cluster: (json['cluster'] as num?)?.toInt(),
  clusterName: json['clusterName'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$SegmentsToJson(Segments instance) => <String, dynamic>{
  'productId': instance.productId,
  'cluster': instance.cluster,
  'clusterName': instance.clusterName,
  'updatedAt': instance.updatedAt,
};

Cluster _$ClusterFromJson(Map<String, dynamic> json) => Cluster(
  id: json['id'] as String?,
  cluster: (json['cluster'] as num?)?.toInt(),
  clusterName: json['clusterName'] as String?,
  numProducts: (json['numProducts'] as num?)?.toInt(),
  avgProfit: (json['avgProfit'] as num?)?.toDouble(),
  totalProfit: (json['totalProfit'] as num?)?.toInt(),
  avgRevenue: (json['avgRevenue'] as num?)?.toDouble(),
  totalRevenue: (json['totalRevenue'] as num?)?.toInt(),
  avgPrice: (json['avgPrice'] as num?)?.toDouble(),
  avgCost: (json['avgCost'] as num?)?.toDouble(),
  avgMargin: (json['avgMargin'] as num?)?.toDouble(),
  avgStock: (json['avgStock'] as num?)?.toInt(),
  avgQuantity: (json['avgQuantity'] as num?)?.toDouble(),
  revenueSharePct: (json['revenueSharePct'] as num?)?.toDouble(),
  profitSharePct: (json['profitSharePct'] as num?)?.toDouble(),
  topProducts: (json['topProducts'] as List<dynamic>?)
      ?.map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
      .toList(),
  bottomProducts: (json['bottomProducts'] as List<dynamic>?)
      ?.map((e) => BottomProduct.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ClusterToJson(Cluster instance) => <String, dynamic>{
  'id': instance.id,
  'cluster': instance.cluster,
  'clusterName': instance.clusterName,
  'numProducts': instance.numProducts,
  'avgProfit': instance.avgProfit,
  'totalProfit': instance.totalProfit,
  'avgRevenue': instance.avgRevenue,
  'totalRevenue': instance.totalRevenue,
  'avgPrice': instance.avgPrice,
  'avgCost': instance.avgCost,
  'avgMargin': instance.avgMargin,
  'avgStock': instance.avgStock,
  'avgQuantity': instance.avgQuantity,
  'revenueSharePct': instance.revenueSharePct,
  'profitSharePct': instance.profitSharePct,
  'topProducts': instance.topProducts,
  'bottomProducts': instance.bottomProducts,
};

TopProduct _$TopProductFromJson(Map<String, dynamic> json) => TopProduct(
  price: (json['price'] as num?)?.toInt(),
  profit: (json['profit'] as num?)?.toInt(),
  productId: json['product_id'] as String?,
  productName: json['product_name'] as String?,
  compositeScore: (json['composite_score'] as num?)?.toDouble(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$TopProductToJson(TopProduct instance) =>
    <String, dynamic>{
      'price': instance.price,
      'profit': instance.profit,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'composite_score': instance.compositeScore,
      'name': instance.name,
    };

BottomProduct _$BottomProductFromJson(Map<String, dynamic> json) =>
    BottomProduct(
      price: (json['price'] as num?)?.toInt(),
      profit: (json['profit'] as num?)?.toInt(),
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String?,
      compositeScore: (json['composite_score'] as num?)?.toDouble(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$BottomProductToJson(BottomProduct instance) =>
    <String, dynamic>{
      'price': instance.price,
      'profit': instance.profit,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'composite_score': instance.compositeScore,
      'name': instance.name,
    };
