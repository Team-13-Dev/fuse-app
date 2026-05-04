// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment_context_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
};

BusinessModel _$BusinessModelFromJson(Map<String, dynamic> json) =>
    BusinessModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tenantSlug: json['tenantSlug'] as String,
      industry: json['industry'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$BusinessModelToJson(BusinessModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tenantSlug': instance.tenantSlug,
      'industry': instance.industry,
      'role': instance.role,
    };

SegmentContextResponseModel _$SegmentContextResponseModelFromJson(
  Map<String, dynamic> json,
) => SegmentContextResponseModel(
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  activeBusinessId: json['activeBusinessId'] as String,
  role: json['role'] as String,
  isOwner: json['isOwner'] as bool,
  businesses: (json['businesses'] as List<dynamic>)
      .map((e) => BusinessModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SegmentContextResponseModelToJson(
  SegmentContextResponseModel instance,
) => <String, dynamic>{
  'user': instance.user,
  'activeBusinessId': instance.activeBusinessId,
  'role': instance.role,
  'isOwner': instance.isOwner,
  'businesses': instance.businesses,
};
