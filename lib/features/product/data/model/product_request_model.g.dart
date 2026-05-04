// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductRequestModel _$ProductRequestModelFromJson(Map<String, dynamic> json) =>
    ProductRequestModel(
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as String,
      stock: (json['stock'] as num).toInt(),
      cost: json['cost'] as String,
    );

Map<String, dynamic> _$ProductRequestModelToJson(
  ProductRequestModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'stock': instance.stock,
  'cost': instance.cost,
};
