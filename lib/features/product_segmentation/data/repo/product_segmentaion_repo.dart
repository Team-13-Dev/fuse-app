import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/api_service.dart';
import 'package:fuse_system/features/product_segmentation/data/model/product_segmentation_response_model.dart';

class ProductSegmentaionRepo {
  final ApiService _apiService;
  ProductSegmentaionRepo(this._apiService);

  Future<ApiResults<ProductSegmentationResponseModel>>
  getProductSegmentation() async {
    try {
      final response = await _apiService.getProductSegmenation();
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }
}
