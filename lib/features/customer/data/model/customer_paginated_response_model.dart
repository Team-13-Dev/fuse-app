import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/features/customer/data/model/customer_response_model.dart';

part 'customer_paginated_response_model.g.dart';

@JsonSerializable()
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}

@JsonSerializable()
class CustomerPaginatedResponse {
  final List<CustomerResponseModel> data;
  final PaginationMeta pagination;

  CustomerPaginatedResponse({required this.data, required this.pagination});

  factory CustomerPaginatedResponse.fromJson(Map<String, dynamic> json) =>
      _$CustomerPaginatedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerPaginatedResponseToJson(this);
}
