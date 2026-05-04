import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/api_service.dart';
import 'package:fuse_system/features/product/data/model/product_request_model.dart';
import 'package:fuse_system/features/product/data/model/product_response_model.dart';

class ProductRepo {
  final ApiService _apiService;
  ProductRepo(this._apiService);
  Future<ApiResults<ProductsData>> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.getProducts(page: page, limit: limit);

      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }

  Future<ApiResults<ProductsData>> searchProducts(
    String search, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.getProducts(
        search: search,
        page: page,
        limit: limit,
      );

      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }

  Future<ApiResults<ProductResponseModel>> createProduct(
    ProductRequestModel productRequestModel,
  ) async {
    try {
      final response = await _apiService.createProduct(productRequestModel);
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }
}
