import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/api_service.dart';
import 'package:fuse_system/features/order/data/model/add_order_request_model.dart';
import 'package:fuse_system/features/order/data/model/add_order_response_model.dart';
import 'package:fuse_system/features/order/data/model/order_response_model.dart';

class OrderRepo {
  final ApiService _apiService;
  OrderRepo(this._apiService);

  Future<ApiResults<OrderData>> fetchOrders({
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await _apiService.getOrders(limit: limit, page: page);
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }

  Future<ApiResults<OrderData>> searchOrders(
    String search, {
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await _apiService.getOrders(
        search: search,
        limit: limit,
        page: page,
      );
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }

  Future<ApiResults<AddOrderResponseModel>> createOrder(
    AddOrderRequestModel addOrderRequestModel,
  ) async {
    try {
      final response = await _apiService.createOrder(addOrderRequestModel);
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }

  Future<ApiResults<void>> deleteOrder(String id) async {
    try {
      final response = await _apiService.deleteOrder(id);
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }
}
