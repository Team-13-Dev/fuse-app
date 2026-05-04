import 'package:fuse_system/core/Networking/api_error_handler.dart';
import 'package:fuse_system/core/Networking/api_results.dart';
import 'package:fuse_system/core/Networking/api_service.dart';

class SignoutRepo {
  final ApiService _apiService;
  SignoutRepo(this._apiService);

  Future<ApiResults<void>> signout() async {
    try {
      final response = await _apiService.signOut();
      return ApiResults.success(response);
    } catch (error) {
      return ApiResults.failure(ErrorHandler.handle(error));
    }
  }
}
