// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_paginated_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'totalPages': instance.totalPages,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
    };

CustomerPaginatedResponse _$CustomerPaginatedResponseFromJson(
  Map<String, dynamic> json,
) => CustomerPaginatedResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => CustomerResponseModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: PaginationMeta.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$CustomerPaginatedResponseToJson(
  CustomerPaginatedResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'pagination': instance.pagination,
};
