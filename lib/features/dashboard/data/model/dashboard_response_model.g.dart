// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardResponseModel _$DashboardResponseModelFromJson(
  Map<String, dynamic> json,
) => DashboardResponseModel(
  metrics: (json['metrics'] as List<dynamic>)
      .map((e) => MetricModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  revenue: (json['revenue'] as List<dynamic>)
      .map((e) => RevenueModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  orderMix: (json['orderMix'] as List<dynamic>)
      .map((e) => OrderMixModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  recent: (json['recent'] as List<dynamic>)
      .map((e) => RecentOrderModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  allTimeRevenue: (json['_allTimeRevenue'] as num).toInt(),
);

Map<String, dynamic> _$DashboardResponseModelToJson(
  DashboardResponseModel instance,
) => <String, dynamic>{
  'metrics': instance.metrics,
  'revenue': instance.revenue,
  'orderMix': instance.orderMix,
  'recent': instance.recent,
  '_allTimeRevenue': instance.allTimeRevenue,
};

MetricModel _$MetricModelFromJson(Map<String, dynamic> json) => MetricModel(
  type: json['type'] as String,
  label: json['label'] as String,
  value: json['value'] as String,
  change: json['change'] as String,
  up: json['up'] as bool,
  sub: json['sub'] as String,
  href: json['href'] as String?,
);

Map<String, dynamic> _$MetricModelToJson(MetricModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'label': instance.label,
      'value': instance.value,
      'change': instance.change,
      'up': instance.up,
      'sub': instance.sub,
      'href': instance.href,
    };

RevenueModel _$RevenueModelFromJson(Map<String, dynamic> json) => RevenueModel(
  label: json['label'] as String,
  value: (json['value'] as num).toInt(),
);

Map<String, dynamic> _$RevenueModelToJson(RevenueModel instance) =>
    <String, dynamic>{'label': instance.label, 'value': instance.value};

OrderMixModel _$OrderMixModelFromJson(Map<String, dynamic> json) =>
    OrderMixModel(
      status: json['status'] as String,
      count: (json['count'] as num).toInt(),
      pct: (json['pct'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderMixModelToJson(OrderMixModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'count': instance.count,
      'pct': instance.pct,
    };

RecentOrderModel _$RecentOrderModelFromJson(Map<String, dynamic> json) =>
    RecentOrderModel(
      orderNumber: json['orderNumber'] as String,
      customerName: json['customerName'] as String,
      total: (json['total'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$RecentOrderModelToJson(RecentOrderModel instance) =>
    <String, dynamic>{
      'orderNumber': instance.orderNumber,
      'customerName': instance.customerName,
      'total': instance.total,
      'status': instance.status,
    };
