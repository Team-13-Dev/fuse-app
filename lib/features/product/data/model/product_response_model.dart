import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_response_model.g.dart';

@JsonSerializable()
class ProductsData {
  final List<ProductResponseModel> data;
  final ProductsPagination pagination;

  ProductsData({required this.data, required this.pagination});

  factory ProductsData.fromJson(Map<String, dynamic> json) =>
      _$ProductsDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsDataToJson(this);
}

@JsonSerializable()
class ProductsPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  ProductsPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ProductsPagination.fromJson(Map<String, dynamic> json) =>
      _$ProductsPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsPaginationToJson(this);
}

@JsonSerializable()
class ProductResponseModel {
  final String id;
  final String businessId; // camelCase matches JSON directly
  final String name;
  final String? description; // nullable
  final String price; // Dart's json_serializable handles "150.00" → double
  final List<String>? imagesUrl; // nullable list, matches "imagesUrl"
  final int stock;
  final String cost;

  ProductResponseModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.description,
    required this.price,
    this.imagesUrl,
    required this.stock,
    required this.cost,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductResponseModelToJson(this);
}
