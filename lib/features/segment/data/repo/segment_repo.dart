import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/api_service.dart';
import 'package:fuse_system/features/segment/data/model/segment_context_response_model.dart';

class SegmentRepo {
  final ApiService _apiService;
  SegmentRepo(this._apiService);

  Future<ApiResults<SegmentContextResponseModel>> getSegment() async {
    try {
      final response = await _apiService.getSegment();
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }
}
