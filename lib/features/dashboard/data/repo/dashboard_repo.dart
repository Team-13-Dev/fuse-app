import 'package:dio/dio.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/api_service.dart';
import 'package:fuse_system/features/dashboard/data/model/dashboard_response_model.dart';

class DashboardRepo {
  final ApiService _apiService;
  DashboardRepo(this._apiService);

  Future<ApiResults<DashboardResponseModel>> getMetrics() async {
    try {
      final response = await _apiService.getMetrics();
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }
}
