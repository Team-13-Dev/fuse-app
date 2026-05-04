import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_request_model.g.dart';

@JsonSerializable()
class ProductRequestModel {
  final String name;
  final String description;
  final String price;
  final int stock;
  final String cost;

  ProductRequestModel({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.cost,
  });

  factory ProductRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ProductRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductRequestModelToJson(this);
}
