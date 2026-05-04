import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/features/product/data/model/product_response_model.dart';
import 'package:fuse_system/features/product/data/repo/product_repo.dart';
import 'package:fuse_system/features/product/logic/cubit/product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepo _productRepo;
  Timer? _debounce;
  int currentPage = 1;
  int totalPages = 1;
  bool isLoadingMore = false;
  bool hasMore = true;
  List<ProductResponseModel> products = [];
  ProductCubit(this._productRepo) : super(const ProductState.initial());

  void getProducts() async {
    currentPage = 1;
    hasMore = true;
    emit(const ProductState.loading());
    final response = await _productRepo.getProducts(page: currentPage);
    response.when(
      success: (productData) {
        products = productData.data;
        hasMore = productData.pagination.hasNext;
        totalPages = productData.pagination.totalPages;
        emit(ProductState.success(products));
      },
      failure: (errorHandler) {
        emit(ProductState.error(errorHandler));
      },
    );
  }

  // void loadMoreProducts() async {
  //   if (isLoadingMore || !hasMore) return;
  //   isLoadingMore = true;
  //   currentPage++;
  //   emit(const ProductState.loading());
  //   final response = await _productRepo.getProducts(page: currentPage);
  //   response.when(
  //     success: (productData) {
  //       products = productData.data;
  //       hasMore = productData.pagination.hasNext;
  //       totalPages = productData.pagination.totalPages;
  //       emit(ProductState.success(products));
  //     },
  //     failure: (errorHandler) {
  //       emit(ProductState.error(errorHandler));
  //     },
  //   );
  // }

  void gotoPage(int page) async {
    if (page < 1 || page > totalPages) return;
    currentPage = page;
    emit(const ProductState.loading());
    final response = await _productRepo.getProducts(page: currentPage);
    response.when(
      success: (productData) {
        products = productData.data;
        hasMore = productData.pagination.hasNext;
        totalPages = productData.pagination.totalPages;
        emit(ProductState.success(products));
      },
      failure: (errorHandler) {
        emit(ProductState.error(errorHandler));
      },
    );
  }

  void loadMoreProducts() async {
    if (isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    currentPage++;
    emit(const ProductState.loading());
    final response = await _productRepo.getProducts(page: currentPage);
    response.when(
      success: (productData) {
        isLoadingMore = false; // ✅ FIX: always reset
        products = productData.data;
        hasMore = productData.pagination.hasNext;
        totalPages = productData.pagination.totalPages;
        emit(ProductState.success(products));
      },
      failure: (errorHandler) {
        isLoadingMore = false; // ✅ FIX: reset on error too
        emit(ProductState.error(errorHandler));
      },
    );
  }

  void searchProducts(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      currentPage = 1;
      hasMore = true;
      emit(const ProductState.loading());
      final response = await _productRepo.searchProducts(
        query,
        page: currentPage,
      );
      response.when(
        success: (productsData) {
          products = productsData.data;
          hasMore = productsData.pagination.hasNext;
          totalPages = productsData.pagination.totalPages;
          emit(ProductState.success(products));
        },
        failure: (errorHandler) {
          emit(ProductState.error(errorHandler));
        },
      );
    });
  }

  // void searchProducts(String query) {
  //   if (_debounce?.isActive ?? false) _debounce!.cancel();
  //   _debounce = Timer(Duration(seconds: 2), () async {
  //     currentPage = 1;
  //     hasMore = true;
  //     emit(const ProductState.loading());
  //     final response = await _productRepo.searchProducts(
  //       query,
  //       page: currentPage,
  //     );
  //     response.when(
  //       success: (productsData) {
  //         products = productsData.data;
  //         hasMore = productsData.pagination.hasNext;
  //         totalPages = productsData.pagination.totalPages;
  //         emit(ProductState.success(products));
  //       },
  //       failure: (errorHandler) {
  //         emit(ProductState.error(errorHandler));
  //       },
  //     );
  //   });
  // }
}
