import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/api_service.dart';
import 'package:fuse_system/features/customer/data/model/customer_paginated_response_model.dart';
import 'package:fuse_system/features/customer/data/model/customer_request_model.dart';
import 'package:fuse_system/features/customer/data/model/customer_response_model.dart';

class CustomerRepo {
  final ApiService _apiService;
  CustomerRepo(this._apiService);

  Future<ApiResults<CustomerPaginatedResponse>> fetchCustomers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.getCustomers(page: page, limit: limit);
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }

  Future<ApiResults<CustomerResponseModel>> createCustomer(
    CustomerRequestModel customerRequestModel,
  ) async {
    try {
      final response = await _apiService.createCustomer(customerRequestModel);
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }

  Future<ApiResults<CustomerPaginatedResponse>> searchCustomers(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.getCustomers(
        search: query,
        page: page,
        limit: limit,
      );
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }

  Future<ApiResults<void>> deleteCustomer(String id) async {
    try {
      final response = await _apiService.deleteCustomer(id);
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }
}
