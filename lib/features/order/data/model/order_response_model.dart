import 'package:json_annotation/json_annotation.dart';

part 'order_response_model.g.dart';

@JsonSerializable()
class OrderData {
  final List<OrderResponseModel> data;
  final OrderPagination pagination;

  OrderData({required this.data, required this.pagination});

  factory OrderData.fromJson(Map<String, dynamic> json) =>
      _$OrderDataFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDataToJson(this);
}

@JsonSerializable()
class OrderPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  OrderPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory OrderPagination.fromJson(Map<String, dynamic> json) =>
      _$OrderPaginationFromJson(json);
  Map<String, dynamic> toJson() => _$OrderPaginationToJson(this);
}

@JsonSerializable()
class OrderResponseModel {
  final String id;
  final String businessId;
  final String status;
  final String total;
  final String createdAt;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;

  OrderResponseModel({
    required this.id,
    required this.businessId,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderResponseModelToJson(this);
}
