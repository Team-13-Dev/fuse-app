import 'package:json_annotation/json_annotation.dart';

part 'add_order_request_model.g.dart';

@JsonSerializable()
class AddOrderRequestModel {
  final String customerId;
  final String address;
  final String? orderVoucher;
  final String? orderDiscount;
  final List<OrderItemRequestModel> items;

  AddOrderRequestModel({
    required this.customerId,
    required this.address,
    this.orderVoucher,
    this.orderDiscount,
    required this.items,
  });

  factory AddOrderRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AddOrderRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddOrderRequestModelToJson(this);
}

@JsonSerializable()
class OrderItemRequestModel {
  final String productId;
  final int quantity;
  final double unitPrice;
  final double itemDiscount;
  final Attributes? attributes;

  OrderItemRequestModel({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.itemDiscount,
    this.attributes,
  });

  factory OrderItemRequestModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemRequestModelToJson(this);
}

@JsonSerializable()
class Attributes {
  final String? size;
  final String? color;

  Attributes({this.size, this.color});

  factory Attributes.fromJson(Map<String, dynamic> json) =>
      _$AttributesFromJson(json);

  Map<String, dynamic> toJson() => _$AttributesToJson(this);
}
