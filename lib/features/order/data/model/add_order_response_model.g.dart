// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_order_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddOrderResponseModel _$AddOrderResponseModelFromJson(
  Map<String, dynamic> json,
) => AddOrderResponseModel(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  customerId: json['customerId'] as String,
  total: json['total'] as String,
  status: json['status'] as String,
  orderVoucher: json['orderVoucher'] as String?,
  orderDiscount: json['orderDiscount'] as String?,
  address: json['address'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$AddOrderResponseModelToJson(
  AddOrderResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'customerId': instance.customerId,
  'total': instance.total,
  'status': instance.status,
  'orderVoucher': instance.orderVoucher,
  'orderDiscount': instance.orderDiscount,
  'address': instance.address,
  'createdAt': instance.createdAt,
};
