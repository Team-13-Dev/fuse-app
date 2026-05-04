import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/api_service.dart';
import 'package:fuse_system/features/categories/data/model/add_categories_request_model.dart';
import 'package:fuse_system/features/categories/data/model/add_categories_response_model.dart';
import 'package:fuse_system/features/categories/data/model/categories_response_model.dart';

class CategoriesRepo {
  final ApiService _apiService;
  CategoriesRepo(this._apiService);

  Future<ApiResults<CategoriesData>> fetchCategories() async {
    try {
      final response = await _apiService.getCategories();
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }

  Future<ApiResults<AddCategoriesResponseModel>> createCategory(
    AddCategoriesRequestModel addCategoriesRequestModel,
  ) async {
    try {
      final response = await _apiService.createCategory(
        addCategoriesRequestModel,
      );
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }
}
