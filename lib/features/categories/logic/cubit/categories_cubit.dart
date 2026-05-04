import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/features/categories/data/model/add_categories_request_model.dart';
import 'package:fuse_system/features/categories/data/model/categories_response_model.dart';
import 'package:fuse_system/features/categories/data/repo/categories_repo.dart';
import 'package:fuse_system/features/categories/logic/cubit/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepo _categoriesRepo;
  List<CategoriesResponseModel> categories = [];
  CategoriesCubit(this._categoriesRepo)
    : super(const CategoriesState.initial());

  void fetchCategories() async {
    emit(const CategoriesState.loading());
    final response = await _categoriesRepo.fetchCategories();
    response.when(
      success: (categoriesResponse) {
        categories = categoriesResponse.data;
        emit(CategoriesState.success(categories));
      },
      failure: (errorHandler) {
        emit(CategoriesState.error(errorHandler));
      },
    );
  }

  void createCategory(
    AddCategoriesRequestModel addCategoriesRequestModel,
  ) async {
    emit(const CategoriesState.loading());

    final response = await _categoriesRepo.createCategory(
      addCategoriesRequestModel,
    );

    response.when(
      success: (data) {
        emit(CategoriesState.createSuccess(data));
      },
      failure: (errorHandler) {
        emit(CategoriesState.error(errorHandler));
      },
    );
  }
}
