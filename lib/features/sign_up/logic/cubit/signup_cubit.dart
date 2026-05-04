import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Helpers/shared_data_helper.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/dio_factory.dart';
import 'package:fuse_system/features/sign_up/data/model/sign_up_request_model.dart';
import 'package:fuse_system/features/sign_up/data/repo/sign_up_repo.dart';
import 'package:fuse_system/features/sign_up/logic/cubit/signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final SignUpRepo _signUpRepo;
  SignupCubit(this._signUpRepo) : super(const SignupState.initial());
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void signup() async {
    emit(SignupState.loading());
    final response = await _signUpRepo.signup(
      SignUpRequestModel(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      ),
    );
    response.when(
      success: (signUpRequestModel) async {
        // await saveUserToken(signUpRequestModel.token);
        emit(SignupState.success(signUpRequestModel));
      },
      failure: (errorHandler) {
        emit(SignupState.error(errorHandler));
      },
    );
  }

  Future<void> saveUserToken(
    String token,
    String businessId,
    String role,
  ) async {
    await SharedDataHelper.setSecuredString('token', token);
    await SharedDataHelper.setSecuredString('businessId', businessId);
    await SharedDataHelper.setSecuredString('role', role);
    //DioFactory.setTokenIntoHeaderAfterLogin(token, businessId, role);
  }
}
