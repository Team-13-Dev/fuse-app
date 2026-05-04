import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_request_model.g.dart';

@JsonSerializable()
class CustomerRequestModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String segment;

  CustomerRequestModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.segment,
  });

  factory CustomerRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerRequestModelToJson(this);
}
