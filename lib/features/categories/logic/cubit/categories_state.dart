import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/features/categories/data/model/add_categories_response_model.dart';
import 'package:fuse_system/features/categories/data/model/categories_response_model.dart';

part 'categories_state.freezed.dart';

@freezed
class CategoriesState with _$CategoriesState {
  const factory CategoriesState.initial() = _Initial;
  const factory CategoriesState.loading() = Loading;
  const factory CategoriesState.createSuccess(
    AddCategoriesResponseModel categories,
  ) = CreateSuccess;
  const factory CategoriesState.success(
    List<CategoriesResponseModel> categories,
  ) = Success;
  const factory CategoriesState.error(ErrorHandler error) = Error;
}
