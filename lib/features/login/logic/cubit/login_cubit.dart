import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:fuse_system/core/Helpers/shared_data_helper.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/dio_factory.dart';
import 'package:fuse_system/features/login/data/model/login_request_body_model.dart';
import 'package:fuse_system/features/login/data/repo/login_repo.dart';
import 'package:fuse_system/features/login/logic/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;
  LoginCubit(this._loginRepo) : super(const LoginState.initial());
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() async {
    emit(const LoginState.loading());
    final response = await _loginRepo.login(
      LoginRequestBodyModel(
        email: emailController.text,
        password: passwordController.text,
      ),
    );
    response.when(
      success: (loginResponseModel) async {
        await saveUserToken(
          loginResponseModel.token,
          loginResponseModel.business.businessId,
          loginResponseModel.business.role,
        );
        emit(LoginState.success(loginResponseModel));
      },
      failure: (errorHandler) {
        emit(LoginState.error(errorHandler));
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
    DioFactory.setTokenIntoHeaderAfterLogin(token, businessId, role);
  }
}
