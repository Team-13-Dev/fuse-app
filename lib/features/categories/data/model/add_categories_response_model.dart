import 'package:json_annotation/json_annotation.dart';

part 'add_categories_response_model.g.dart';

@JsonSerializable()
class AddCategoriesResponseModel {
  final String id;
  final String? businessId;
  final String? parentId;
  final String? name;
  final String? slug;
  final String? description;
  final String? imageUrl;

  AddCategoriesResponseModel({
    required this.id,
    required this.businessId,
    this.parentId,
    this.name,
    this.slug,
    this.description,
    this.imageUrl,
  });

  factory AddCategoriesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AddCategoriesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddCategoriesResponseModelToJson(this);
}
