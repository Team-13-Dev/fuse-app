// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_categories_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddCategoriesRequestModel _$AddCategoriesRequestModelFromJson(
  Map<String, dynamic> json,
) => AddCategoriesRequestModel(
  name: json['name'] as String,
  parentId: json['parentId'] as String?,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$AddCategoriesRequestModelToJson(
  AddCategoriesRequestModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'parentId': instance.parentId,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
};
