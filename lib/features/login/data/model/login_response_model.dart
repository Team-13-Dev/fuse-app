import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  final String token;
  final BusinessResponseModel business;

  LoginResponseModel({required this.token, required this.business});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);
}

@JsonSerializable()
class BusinessResponseModel {
  final String businessId;
  final String role;

  BusinessResponseModel({required this.businessId, required this.role});

  factory BusinessResponseModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessResponseModelFromJson(json);
}
