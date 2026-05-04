import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/features/categories/data/model/categories_response_model.dart';

part 'customer_response_model.g.dart';

@JsonSerializable()
class DataResponse {
  final List<CategoriesResponseModel> data;
  DataResponse({required this.data});
  factory DataResponse.fromJson(Map<String, dynamic> json) =>
      _$DataResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DataResponseToJson(this);
}

@JsonSerializable()
class CustomerResponseModel {
  final String id;
  final String businessId;
  final String? clerkId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? segment;

  CustomerResponseModel({
    required this.id,
    required this.businessId,
    this.clerkId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.segment,
  });

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerResponseModelToJson(this);
}
