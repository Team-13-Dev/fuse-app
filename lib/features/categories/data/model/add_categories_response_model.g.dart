// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_categories_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddCategoriesResponseModel _$AddCategoriesResponseModelFromJson(
  Map<String, dynamic> json,
) => AddCategoriesResponseModel(
  id: json['id'] as String,
  businessId: json['businessId'] as String?,
  parentId: json['parentId'] as String?,
  name: json['name'] as String?,
  slug: json['slug'] as String?,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$AddCategoriesResponseModelToJson(
  AddCategoriesResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'parentId': instance.parentId,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
};
