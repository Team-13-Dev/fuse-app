import 'package:bloc/bloc.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/features/product/data/model/product_request_model.dart';
import 'package:fuse_system/features/product/data/model/product_response_model.dart';
import 'package:fuse_system/features/product/data/repo/product_repo.dart';
import 'package:fuse_system/features/product/logic/cubit/add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final ProductRepo _productRepo;

  AddProductCubit(this._productRepo) : super(const AddProductState.initial());

  void createProduct({
    required String name,
    required String description,
    required String price,
    required int stock,
    required String cost,
  }) async {
    emit(const AddProductState.loading());

    final productRequest = ProductRequestModel(
      name: name,
      description: description,
      price: price,
      stock: stock,
      cost: cost,
    );

    final response = await _productRepo.createProduct(productRequest);

    response.when(
      success: (data) {
        emit(AddProductState.success(data));
      },
      failure: (errorHandler) {
        emit(AddProductState.error(errorHandler));
      },
    );
  }
}
