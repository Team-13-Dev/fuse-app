// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataResponse _$DataResponseFromJson(Map<String, dynamic> json) => DataResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => CategoriesResponseModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DataResponseToJson(DataResponse instance) =>
    <String, dynamic>{'data': instance.data};

CustomerResponseModel _$CustomerResponseModelFromJson(
  Map<String, dynamic> json,
) => CustomerResponseModel(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  clerkId: json['clerkId'] as String?,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  segment: json['segment'] as String?,
);

Map<String, dynamic> _$CustomerResponseModelToJson(
  CustomerResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'clerkId': instance.clerkId,
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'segment': instance.segment,
};
