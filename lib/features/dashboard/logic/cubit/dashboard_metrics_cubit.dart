import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/features/dashboard/data/repo/dashboard_repo.dart';
import 'package:fuse_system/features/dashboard/logic/cubit/dashboard_metrics_state.dart';

class DashboardMetricsCubit extends Cubit<DashboardMetricsState> {
  final DashboardRepo _dashboardRepo;
  DashboardMetricsCubit(this._dashboardRepo)
    : super(const DashboardMetricsState.initial());

  void fetchMetrics() async {
    emit(const DashboardMetricsState.loading());
    final response = await _dashboardRepo.getMetrics();
    response.when(
      success: (data) {
        emit(DashboardMetricsState.success(data));
      },
      failure: (errorHandler) {
        emit(DashboardMetricsState.error(errorHandler));
      },
    );
  }
}
