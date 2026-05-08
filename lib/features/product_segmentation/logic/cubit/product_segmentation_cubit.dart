import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/features/product_segmentation/data/repo/product_segmentaion_repo.dart';
import 'package:fuse_system/features/product_segmentation/logic/cubit/product_segmentation_state.dart';

class ProductSegmentationCubit extends Cubit<ProductSegmentationState> {
  final ProductSegmentaionRepo _productSegmentaionRepo;
  ProductSegmentationCubit(this._productSegmentaionRepo)
    : super(const ProductSegmentationState.initial());

  void getProductSegmentation() async {
    emit(const ProductSegmentationState.loading());
    final response = await _productSegmentaionRepo.getProductSegmentation();
    response.when(
      success: (data) {
        emit(ProductSegmentationState.success(data));
      },
      failure: (errorHandler) {
        emit(ProductSegmentationState.error(errorHandler));
      },
    );
  }
}
