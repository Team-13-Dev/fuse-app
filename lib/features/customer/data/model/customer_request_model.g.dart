// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerRequestModel _$CustomerRequestModelFromJson(
  Map<String, dynamic> json,
) => CustomerRequestModel(
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  segment: json['segment'] as String,
);

Map<String, dynamic> _$CustomerRequestModelToJson(
  CustomerRequestModel instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'segment': instance.segment,
};
