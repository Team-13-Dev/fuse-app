import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/features/dashboard/data/model/dashboard_response_model.dart';
part 'dashboard_metrics_state.freezed.dart';

@freezed
class DashboardMetricsState with _$DashboardMetricsState {
  const factory DashboardMetricsState.initial() = _Initial;
  const factory DashboardMetricsState.loading() = Loading;
  const factory DashboardMetricsState.success(DashboardResponseModel data) =
      Success;
  const factory DashboardMetricsState.error(ErrorHandler errorHandler) = Error;
}
