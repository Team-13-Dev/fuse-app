import 'package:dio/dio.dart';
import 'package:fuse_system/core/Helpers/shared_data_helper.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  DioFactory._();

  static Dio? dio;

  static Dio getDio() {
    Duration timeOut = const Duration(seconds: 30);

    if (dio == null) {
      dio = Dio();
      dio!
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut;
      addDioHeaders();
      addDioInterceptor();
      return dio!;
    } else {
      return dio!;
    }
  }

  static Future<void> addDioHeaders() async {
    dio?.options.headers = {
      'Accept': 'application/json',
      'Authorization':
          'Bearer Bearer ${await SharedDataHelper.getSecuredString('token')}',
      'x-business-id': await SharedDataHelper.getSecuredString('businessId'),
      'x-business-role': await SharedDataHelper.getSecuredString('role'),
    };
  }

  static void setTokenIntoHeaderAfterLogin(
    String token,
    String businessId,
    String role,
  ) {
    dio?.options.headers.addAll({
      'Authorization': 'Bearer Bearer $token',
      'x-business-id': businessId,
      'x-business-role': role,
    });
  }

  static void setBusinessAndRoleIntoHeaderAfterSwitch(
    String businessId,
    String role,
  ) {
    dio?.options.headers.addAll({
      'x-business-id': businessId,
      'x-business-role': role,
    });
  }

  static void addDioInterceptor() {
    dio?.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
        //logPrint: (obj) => print(obj),
      ),
    );
  }
}
