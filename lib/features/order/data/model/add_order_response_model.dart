import 'package:json_annotation/json_annotation.dart';

part 'add_order_response_model.g.dart';

@JsonSerializable()
class AddOrderResponseModel {
  final String id;
  final String businessId;
  final String customerId;
  final String total;
  final String status;
  final String? orderVoucher;
  final String? orderDiscount;
  final String? address;
  final String createdAt;

  AddOrderResponseModel({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.total,
    required this.status,
    this.orderVoucher,
    this.orderDiscount,
    this.address,
    required this.createdAt,
  });

  factory AddOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AddOrderResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddOrderResponseModelToJson(this);
}
