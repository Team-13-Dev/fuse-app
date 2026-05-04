import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/features/order/data/model/add_order_request_model.dart';
import 'package:fuse_system/features/order/data/model/order_response_model.dart';
import 'package:fuse_system/features/order/data/repo/order_repo.dart';
import 'package:fuse_system/features/order/logic/cubit/order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepo _orderRepo;
  Timer? _debounce;
  int currentPage = 1;
  int totalPages = 1;
  bool isLoadingMore = false;
  bool hasMore = true;
  List<OrderResponseModel> orders = [];

  OrderCubit(this._orderRepo) : super(const OrderState.initial());

  void fetchOrders() async {
    currentPage = 1;
    hasMore = true;
    emit(const OrderState.loading());
    final response = await _orderRepo.fetchOrders(page: currentPage);
    response.when(
      success: (orderData) {
        orders = orderData.data;
        hasMore = orderData.pagination.hasNext;
        totalPages = orderData.pagination.totalPages;
        emit(OrderState.success(orders));
      },
      failure: (errorHandler) {
        emit(OrderState.error(errorHandler));
      },
    );
  }

  void loadMoreOrders() async {
    if (isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    currentPage++;
    emit(const OrderState.loading());
    final response = await _orderRepo.fetchOrders(page: currentPage);
    response.when(
      success: (orderData) {
        isLoadingMore = false; // ✅ FIX: always reset
        orders = orderData.data;
        hasMore = orderData.pagination.hasNext;
        totalPages = orderData.pagination.totalPages;
        emit(OrderState.success(orders));
      },
      failure: (errorHandler) {
        isLoadingMore = false; // ✅ FIX: reset on error too
        emit(OrderState.error(errorHandler));
      },
    );
  }

  void gotoPage(int page) async {
    if (page < 1 || page > totalPages) return;
    currentPage = page;
    emit(const OrderState.loading());
    final response = await _orderRepo.fetchOrders(page: currentPage);
    response.when(
      success: (orderData) {
        orders = orderData.data;
        hasMore = orderData.pagination.hasNext;
        totalPages = orderData.pagination.totalPages;
        emit(OrderState.success(orders));
      },
      failure: (errorHandler) {
        emit(OrderState.error(errorHandler));
      },
    );
  }

  void searchOrders(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      // ✅ FIX: reset page on new search
      currentPage = 1;
      hasMore = true;
      emit(const OrderState.loading());
      final response = await _orderRepo.searchOrders(query, page: currentPage);
      response.when(
        success: (orderData) {
          orders = orderData.data;
          hasMore = orderData.pagination.hasNext;
          totalPages = orderData.pagination.totalPages;
          emit(OrderState.success(orders));
        },
        failure: (errorHandler) {
          emit(OrderState.error(errorHandler));
        },
      );
    });
  }

  void createOrder(AddOrderRequestModel addOrderRequestModel) async {
    emit(const OrderState.loading());
    final response = await _orderRepo.createOrder(addOrderRequestModel);
    response.when(
      success: (data) {
        emit(OrderState.successCreate(data));
      },
      failure: (errorHandler) {
        emit(OrderState.error(errorHandler));
      },
    );
  }

  void deleteOrder(String id) async {
    emit(const OrderState.loading());
    final response = await _orderRepo.deleteOrder(id);
    response.when(
      success: (data) {
        emit(const OrderState.successDelete());
      },
      failure: (errorHandler) {
        emit(OrderState.error(errorHandler));
      },
    );
  }
}
