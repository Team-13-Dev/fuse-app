import 'package:json_annotation/json_annotation.dart';

part 'categories_response_model.g.dart';

@JsonSerializable()
class CategoriesData {
  final List<CategoriesResponseModel> data;
  CategoriesData({required this.data});
  factory CategoriesData.fromJson(Map<String, dynamic> json) =>
      _$CategoriesDataFromJson(json);

  Map<String, dynamic> toJson() => _$CategoriesDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CategoriesResponseModel {
  final String id;
  final String businessId;
  final String? parentId;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final List<CategoriesResponseModel> children;

  CategoriesResponseModel({
    required this.id,
    required this.businessId,
    this.parentId,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    required this.children,
  });

  factory CategoriesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CategoriesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoriesResponseModelToJson(this);
}
