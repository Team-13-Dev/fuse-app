import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_segmentation_response_model.g.dart';

@JsonSerializable()
class ProductSegmentationResponseModel {
  final bool? hasResults;
  final int? productCount;
  final int? minProductsNeeded;
  final String? lastJobAt;
  final List<Segments>? segments;
  final List<Cluster>? clusters;

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

@JsonSerializable()
class Segments {
  final String? productId;
  final int? cluster;
  final String? clusterName;
  final String? updatedAt;
  Segments({this.productId, this.cluster, this.clusterName, this.updatedAt});

  factory Segments.fromJson(Map<String, dynamic> json) =>
      _$SegmentsFromJson(json);
}

@JsonSerializable()
class Cluster {
  final String? id;
  final int? cluster;
  final String? clusterName;
  final int? numProducts;
  final double? avgProfit;
  final int? totalProfit;
  final double? avgRevenue;
  final int? totalRevenue;
  final double? avgPrice;
  final double? avgCost;
  final double? avgMargin;
  final int? avgStock;
  final double? avgQuantity;
  final double? revenueSharePct;
  final double? profitSharePct;

  final List<TopProduct>? topProducts;
  final List<BottomProduct>? bottomProducts;

  Cluster({
    required this.id,
    required this.cluster,
    required this.clusterName,
    required this.numProducts,
    required this.avgProfit,
    required this.totalProfit,
    required this.avgRevenue,
    required this.totalRevenue,
    required this.avgPrice,
    required this.avgCost,
    required this.avgMargin,
    required this.avgStock,
    required this.avgQuantity,
    required this.revenueSharePct,
    required this.profitSharePct,
    this.topProducts,
    this.bottomProducts,
  });

  factory Cluster.fromJson(Map<String, dynamic> json) =>
      _$ClusterFromJson(json);

  Map<String, dynamic> toJson() => _$ClusterToJson(this);
}

@JsonSerializable()
class TopProduct {
  final int? price;
  final int? profit;
  @JsonKey(name: 'product_id')
  final String? productId;
  @JsonKey(name: 'product_name')
  final String? productName;
  @JsonKey(name: 'composite_score')
  final double? compositeScore;
  final String? name;

  TopProduct({
    required this.price,
    required this.profit,
    required this.productId,
    required this.productName,
    required this.compositeScore,
    required this.name,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) =>
      _$TopProductFromJson(json);

  Map<String, dynamic> toJson() => _$TopProductToJson(this);
}

@JsonSerializable()
class BottomProduct {
  final int? price;
  final int? profit;
  @JsonKey(name: 'product_id')
  final String? productId;
  @JsonKey(name: 'product_name')
  final String? productName;
  @JsonKey(name: 'composite_score')
  final double? compositeScore;
  final String? name;

  BottomProduct({
    required this.price,
    required this.profit,
    required this.productId,
    required this.productName,
    required this.compositeScore,
    required this.name,
  });

  factory BottomProduct.fromJson(Map<String, dynamic> json) =>
      _$BottomProductFromJson(json);
}
