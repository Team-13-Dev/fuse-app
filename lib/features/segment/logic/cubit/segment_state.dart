import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/features/segment/data/model/segment_context_response_model.dart';

part 'segment_state.freezed.dart';

@freezed
class SegmentState with _$SegmentState {
  const factory SegmentState.initial() = _Initial;
  const factory SegmentState.loading() = _Loading;
  const factory SegmentState.success(SegmentContextResponseModel segment) =
      _Success;
  const factory SegmentState.failure(ErrorHandler errorHandler) = _Failure;
}
