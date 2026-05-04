// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoriesData _$CategoriesDataFromJson(Map<String, dynamic> json) =>
    CategoriesData(
      data: (json['data'] as List<dynamic>)
          .map(
            (e) => CategoriesResponseModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$CategoriesDataToJson(CategoriesData instance) =>
    <String, dynamic>{'data': instance.data};

CategoriesResponseModel _$CategoriesResponseModelFromJson(
  Map<String, dynamic> json,
) => CategoriesResponseModel(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  parentId: json['parentId'] as String?,
  name: json['name'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  children: (json['children'] as List<dynamic>)
      .map((e) => CategoriesResponseModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoriesResponseModelToJson(
  CategoriesResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'parentId': instance.parentId,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'children': instance.children.map((e) => e.toJson()).toList(),
};
