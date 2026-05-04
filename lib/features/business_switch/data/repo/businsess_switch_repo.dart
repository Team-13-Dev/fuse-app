import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/api_service.dart';
import 'package:fuse_system/features/business_switch/data/model/business_switch_request_model.dart';
import 'package:fuse_system/features/business_switch/data/model/business_switch_response_model.dart';

class BusinsessSwitchRepo {
  final ApiService _apiService;
  BusinsessSwitchRepo(this._apiService);

  Future<ApiResults<BusinessSwitchResponseModel>> businessSwitch(
    BusinessSwitchRequestModel businessSwitchRequestModel,
  ) async {
    try {
      final response = await _apiService.businessSwitch(
        businessSwitchRequestModel,
      );
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }
}
