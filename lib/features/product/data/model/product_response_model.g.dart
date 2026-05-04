// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductsData _$ProductsDataFromJson(Map<String, dynamic> json) => ProductsData(
  data: (json['data'] as List<dynamic>)
      .map((e) => ProductResponseModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: ProductsPagination.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ProductsDataToJson(ProductsData instance) =>
    <String, dynamic>{'data': instance.data, 'pagination': instance.pagination};

ProductsPagination _$ProductsPaginationFromJson(Map<String, dynamic> json) =>
    ProductsPagination(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );

Map<String, dynamic> _$ProductsPaginationToJson(ProductsPagination instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'totalPages': instance.totalPages,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
    };

ProductResponseModel _$ProductResponseModelFromJson(
  Map<String, dynamic> json,
) => ProductResponseModel(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  price: json['price'] as String,
  imagesUrl: (json['imagesUrl'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  stock: (json['stock'] as num).toInt(),
  cost: json['cost'] as String,
);

Map<String, dynamic> _$ProductResponseModelToJson(
  ProductResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'imagesUrl': instance.imagesUrl,
  'stock': instance.stock,
  'cost': instance.cost,
};
