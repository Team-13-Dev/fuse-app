import 'package:json_annotation/json_annotation.dart';

part 'dashboard_response_model.g.dart';

@JsonSerializable()
class DashboardResponseModel {
  final List<MetricModel> metrics;
  final List<RevenueModel> revenue;
  final List<OrderMixModel> orderMix;
  final List<RecentOrderModel> recent;

  @JsonKey(name: '_allTimeRevenue')
  final int allTimeRevenue;

  DashboardResponseModel({
    required this.metrics,
    required this.revenue,
    required this.orderMix,
    required this.recent,
    required this.allTimeRevenue,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardResponseModelToJson(this);
}

@JsonSerializable()
class MetricModel {
  final String type;
  final String label;
  final String value;
  final String change;
  final bool up;
  final String sub;
  final String? href;

  MetricModel({
    required this.type,
    required this.label,
    required this.value,
    required this.change,
    required this.up,
    required this.sub,
    this.href,
  });

  factory MetricModel.fromJson(Map<String, dynamic> json) =>
      _$MetricModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetricModelToJson(this);
}

@JsonSerializable()
class RevenueModel {
  final String label;
  final int value;

  RevenueModel({required this.label, required this.value});

  factory RevenueModel.fromJson(Map<String, dynamic> json) =>
      _$RevenueModelFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueModelToJson(this);
}

@JsonSerializable()
class OrderMixModel {
  final String status;
  final int count;
  final double pct;

  OrderMixModel({required this.status, required this.count, required this.pct});

  factory OrderMixModel.fromJson(Map<String, dynamic> json) =>
      _$OrderMixModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderMixModelToJson(this);
}

@JsonSerializable()
class RecentOrderModel {
  final String orderNumber;
  final String customerName;
  final int total;
  final String status;

  RecentOrderModel({
    required this.orderNumber,
    required this.customerName,
    required this.total,
    required this.status,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) =>
      _$RecentOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecentOrderModelToJson(this);
}
