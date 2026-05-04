import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/api_service.dart';
import 'package:fuse_system/features/sign_up/data/model/sign_up_request_model.dart';
import 'package:fuse_system/features/sign_up/data/model/sign_up_response_model.dart';

class SignUpRepo {
  final ApiService _apiService;
  SignUpRepo(this._apiService);

  Future<ApiResults<SignUpResponseModel>> signup(
    SignUpRequestModel signUpRequstModel,
  ) async {
    try {
      final response = await _apiService.signUp(signUpRequstModel);
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }
}
