// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) =>
    LoginResponseModel(
      token: json['token'] as String,
      business: BusinessResponseModel.fromJson(
        json['business'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$LoginResponseModelToJson(LoginResponseModel instance) =>
    <String, dynamic>{'token': instance.token, 'business': instance.business};

BusinessResponseModel _$BusinessResponseModelFromJson(
  Map<String, dynamic> json,
) => BusinessResponseModel(
  businessId: json['businessId'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$BusinessResponseModelToJson(
  BusinessResponseModel instance,
) => <String, dynamic>{
  'businessId': instance.businessId,
  'role': instance.role,
};
