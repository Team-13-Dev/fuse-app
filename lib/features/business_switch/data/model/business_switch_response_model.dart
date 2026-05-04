import 'package:json_annotation/json_annotation.dart';

part 'business_switch_response_model.g.dart';

@JsonSerializable()
class BusinessSwitchResponseModel {
  final String businessId;
  final String role;

  BusinessSwitchResponseModel({required this.businessId, required this.role});

  factory BusinessSwitchResponseModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessSwitchResponseModelFromJson(json);
}
