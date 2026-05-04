import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Helpers/shared_data_helper.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/dio_factory.dart';
import 'package:fuse_system/features/business_switch/data/model/business_switch_request_model.dart';
import 'package:fuse_system/features/business_switch/data/repo/businsess_switch_repo.dart';
import 'package:fuse_system/features/business_switch/logic/cubit/business_switch_state.dart';

class BusinessSwitchCubit extends Cubit<BusinessSwitchState> {
  final BusinsessSwitchRepo _businsessSwitchRepo;
  BusinessSwitchCubit(this._businsessSwitchRepo)
    : super(const BusinessSwitchState.initial());

  void businessSwitch(
    BusinessSwitchRequestModel businessSwitchRequestModel,
  ) async {
    emit(const BusinessSwitchState.loading());
    final response = await _businsessSwitchRepo.businessSwitch(
      businessSwitchRequestModel,
    );
    response.when(
      success: (data) async {
        await updateSharedDataValues(data.role, data.businessId);
        emit(BusinessSwitchState.success(data));
      },
      failure: (errorHandler) {
        emit(BusinessSwitchState.error(errorHandler));
      },
    );
  }

  Future updateSharedDataValues(String role, String businessId) async {
    // await SharedDataHelper.deleteSecuredString("businessId");
    // await SharedDataHelper.deleteSecuredString("role");
    await SharedDataHelper.setSecuredString("businessId", businessId);
    await SharedDataHelper.setSecuredString("role", role);
    DioFactory.setBusinessAndRoleIntoHeaderAfterSwitch(businessId, role);
  }
}
