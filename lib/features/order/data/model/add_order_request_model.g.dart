// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_order_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddOrderRequestModel _$AddOrderRequestModelFromJson(
  Map<String, dynamic> json,
) => AddOrderRequestModel(
  customerId: json['customerId'] as String,
  address: json['address'] as String,
  orderVoucher: json['orderVoucher'] as String?,
  orderDiscount: json['orderDiscount'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemRequestModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AddOrderRequestModelToJson(
  AddOrderRequestModel instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'address': instance.address,
  'orderVoucher': instance.orderVoucher,
  'orderDiscount': instance.orderDiscount,
  'items': instance.items,
};

OrderItemRequestModel _$OrderItemRequestModelFromJson(
  Map<String, dynamic> json,
) => OrderItemRequestModel(
  productId: json['productId'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  itemDiscount: (json['itemDiscount'] as num).toDouble(),
  attributes: json['attributes'] == null
      ? null
      : Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderItemRequestModelToJson(
  OrderItemRequestModel instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
  'itemDiscount': instance.itemDiscount,
  'attributes': instance.attributes,
};

Attributes _$AttributesFromJson(Map<String, dynamic> json) =>
    Attributes(size: json['size'] as String?, color: json['color'] as String?);

Map<String, dynamic> _$AttributesToJson(Attributes instance) =>
    <String, dynamic>{'size': instance.size, 'color': instance.color};
