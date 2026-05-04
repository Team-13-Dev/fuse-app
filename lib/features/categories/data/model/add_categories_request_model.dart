import 'package:json_annotation/json_annotation.dart';

part 'add_categories_request_model.g.dart';

@JsonSerializable()
class AddCategoriesRequestModel {
  final String name;
  final String? parentId;
  final String? description;
  final String? imageUrl;

  AddCategoriesRequestModel({
    required this.name,
    this.parentId,
    this.description,
    this.imageUrl,
  });

  factory AddCategoriesRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AddCategoriesRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddCategoriesRequestModelToJson(this);
}
