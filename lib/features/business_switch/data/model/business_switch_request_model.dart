import 'package:json_annotation/json_annotation.dart';

part 'business_switch_request_model.g.dart';

@JsonSerializable()
class BusinessSwitchRequestModel {
  final String businessId;

  BusinessSwitchRequestModel({required this.businessId});

  Map<String, dynamic> toJson() => _$BusinessSwitchRequestModelToJson(this);
}
