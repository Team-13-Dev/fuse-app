import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Helpers/shared_data_helper.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/features/drawer_navigation/data/repo/signout_repo.dart';
import 'package:fuse_system/features/drawer_navigation/logic/cubit/signout_state.dart';

class SignoutCubit extends Cubit<SignoutState> {
  final SignoutRepo _signoutRepo;
  SignoutCubit(this._signoutRepo) : super(const SignoutState.initial());

  void signOut() async {
    emit(const SignoutState.loading());
    final response = await _signoutRepo.signout();
    response.when(
      success: (data) async {
        await SharedDataHelper.deleteSecuredString("token");
        await SharedDataHelper.deleteSecuredString("businessId");
        await SharedDataHelper.deleteSecuredString("role");
        emit(SignoutState.success());
      },
      failure: (errorHandler) {
        emit(SignoutState.error(errorHandler));
      },
    );
  }
}
