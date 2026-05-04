import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/features/customer/data/model/customer_request_model.dart';
import 'package:fuse_system/features/customer/data/model/customer_response_model.dart';
import 'package:fuse_system/features/customer/data/repo/customer_repo.dart';
import 'package:fuse_system/features/customer/logic/cubit/customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepo _customerRepo;
  Timer? _debounce;

  int currentPage = 1;
  int totalPages = 1;
  bool isLoadingMore = false;
  bool hasMore = true;

  List<CustomerResponseModel> customers = [];

  CustomerCubit(this._customerRepo) : super(const CustomerState.initial());

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<void> createCustomer(CustomerRequestModel customerRequestModel) async {
    emit(const CustomerState.loading());
    final response = await _customerRepo.createCustomer(customerRequestModel);
    response.when(
      success: (data) => emit(CustomerState.successCreate(data)),
      failure: (errorHandler) => emit(CustomerState.error(errorHandler)),
    );
  }

  // ── FETCH (first page) ────────────────────────────────────────────────────
  Future<void> fetchCustomers() async {
    currentPage = 1;
    hasMore = true;
    emit(const CustomerState.loading());

    final response = await _customerRepo.fetchCustomers(page: currentPage);

    response.when(
      success: (paginatedResponse) {
        customers = paginatedResponse.data;
        hasMore = paginatedResponse.pagination.hasNext;
        totalPages = paginatedResponse.pagination.totalPages;
        emit(CustomerState.success(customers));
      },
      failure: (error) => emit(CustomerState.error(error)),
    );
  }

  // ── LOAD MORE (infinite scroll — kept for backward compat) ────────────────
  Future<void> loadMoreCustomers() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    currentPage++;

    final response = await _customerRepo.fetchCustomers(page: currentPage);

    response.when(
      success: (paginatedResponse) {
        customers.addAll(paginatedResponse.data);
        hasMore = paginatedResponse.pagination.hasNext;
        totalPages = paginatedResponse.pagination.totalPages;
        emit(CustomerState.success(List.of(customers)));
      },
      failure: (error) {
        currentPage--;
        emit(CustomerState.error(error));
      },
    );

    isLoadingMore = false;
  }

  // ── GO TO SPECIFIC PAGE ───────────────────────────────────────────────────
  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages) return;

    currentPage = page;
    emit(const CustomerState.loading());

    final response = await _customerRepo.fetchCustomers(page: currentPage);

    response.when(
      success: (paginatedResponse) {
        customers = paginatedResponse.data;
        hasMore = paginatedResponse.pagination.hasNext;
        totalPages = paginatedResponse.pagination.totalPages;
        emit(CustomerState.success(List.of(customers)));
      },
      failure: (error) {
        emit(CustomerState.error(error));
      },
    );
  }

  // ── SEARCH ────────────────────────────────────────────────────────────────
  void searchCustomers(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 2000), () async {
      currentPage = 1;
      hasMore = true;
      emit(const CustomerState.loading());

      final response = await _customerRepo.searchCustomers(
        query,
        page: currentPage,
      );

      response.when(
        success: (paginatedResponse) {
          customers = paginatedResponse.data;
          hasMore = paginatedResponse.pagination.hasNext;
          totalPages = paginatedResponse.pagination.totalPages;
          emit(CustomerState.success(customers));
        },
        failure: (error) => emit(CustomerState.error(error)),
      );
    });
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  void deleteCustomer(String id) async {
    emit(const CustomerState.loading());
    final response = await _customerRepo.deleteCustomer(id);
    response.when(
      success: (_) => emit(CustomerState.successDelete()),
      failure: (errorHandler) => emit(CustomerState.error(errorHandler)),
    );
  }
}
