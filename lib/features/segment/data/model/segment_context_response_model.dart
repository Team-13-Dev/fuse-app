import 'package:freezed_annotation/freezed_annotation.dart';

part 'segment_context_response_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;

  const UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class BusinessModel {
  final String id;
  final String name;
  final String tenantSlug;
  final String industry;
  final String role;

  const BusinessModel({
    required this.id,
    required this.name,
    required this.tenantSlug,
    required this.industry,
    required this.role,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessModelFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessModelToJson(this);
}

@JsonSerializable()
class SegmentContextResponseModel {
  final UserModel user;
  final String activeBusinessId;
  final String role;
  final bool isOwner;
  final List<BusinessModel> businesses;

  const SegmentContextResponseModel({
    required this.user,
    required this.activeBusinessId,
    required this.role,
    required this.isOwner,
    required this.businesses,
  });

  factory SegmentContextResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SegmentContextResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SegmentContextResponseModelToJson(this);
}
