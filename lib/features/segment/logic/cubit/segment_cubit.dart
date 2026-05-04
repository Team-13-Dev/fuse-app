import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/features/segment/data/repo/segment_repo.dart';
import 'package:fuse_system/features/segment/logic/cubit/segment_state.dart';

class SegmentCubit extends Cubit<SegmentState> {
  final SegmentRepo _segmentRepo;

  SegmentCubit(this._segmentRepo) : super(const SegmentState.initial());

  Future<void> getSegment() async {
    emit(const SegmentState.loading());

    final response = await _segmentRepo.getSegment();

    response.when(
      success: (segment) {
        emit(SegmentState.success(segment));
      },
      failure: (errorHandler) {
        emit(SegmentState.failure(errorHandler));
      },
    );
  }
}
