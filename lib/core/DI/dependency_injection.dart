import 'package:dio/dio.dart';
import 'package:fuse_system/core/Networking/api_service.dart';
import 'package:fuse_system/core/Networking/dio_factory.dart';
import 'package:fuse_system/features/business_switch/data/repo/businsess_switch_repo.dart';
import 'package:fuse_system/features/business_switch/logic/cubit/business_switch_cubit.dart';
import 'package:fuse_system/features/categories/data/repo/categories_repo.dart';
import 'package:fuse_system/features/categories/logic/cubit/categories_cubit.dart';
import 'package:fuse_system/features/customer/data/repo/customer_repo.dart';
import 'package:fuse_system/features/customer/logic/cubit/customer_cubit.dart';
import 'package:fuse_system/features/dashboard/data/repo/dashboard_repo.dart';
import 'package:fuse_system/features/dashboard/logic/cubit/dashboard_metrics_cubit.dart';
import 'package:fuse_system/features/drawer_navigation/data/repo/signout_repo.dart';
import 'package:fuse_system/features/drawer_navigation/logic/cubit/signout_cubit.dart';
import 'package:fuse_system/features/login/data/repo/login_repo.dart';
import 'package:fuse_system/features/login/logic/cubit/login_cubit.dart';
import 'package:fuse_system/features/order/data/repo/order_repo.dart';
import 'package:fuse_system/features/order/logic/cubit/order_cubit.dart';
import 'package:fuse_system/features/product/data/repo/product_repo.dart';
import 'package:fuse_system/features/product/logic/cubit/add_product_cubit.dart';
import 'package:fuse_system/features/product/logic/cubit/product_cubit.dart';
import 'package:fuse_system/features/segment/data/repo/segment_repo.dart';
import 'package:fuse_system/features/segment/logic/cubit/segment_cubit.dart';
import 'package:fuse_system/features/sign_up/data/repo/sign_up_repo.dart';
import 'package:fuse_system/features/sign_up/logic/cubit/signup_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  Dio dio = DioFactory.getDio();

  getIt.registerLazySingleton<ApiService>(() => ApiService(dio));

  // login
  getIt.registerFactory<LoginRepo>(() => LoginRepo(getIt()));
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));
  // sign up
  getIt.registerFactory<SignUpRepo>(() => SignUpRepo(getIt()));
  getIt.registerFactory<SignupCubit>(() => SignupCubit(getIt()));
  // sign out
  getIt.registerFactory<SignoutRepo>(() => SignoutRepo(getIt()));
  getIt.registerFactory<SignoutCubit>(() => SignoutCubit(getIt()));

  // product
  getIt.registerFactory<ProductRepo>(() => ProductRepo(getIt()));
  getIt.registerFactory<ProductCubit>(() => ProductCubit(getIt()));

  // Add Product
  getIt.registerFactory<AddProductCubit>(() => AddProductCubit(getIt()));

  // get customers
  getIt.registerFactory<CustomerRepo>(() => CustomerRepo(getIt()));
  getIt.registerFactory<CustomerCubit>(() => CustomerCubit(getIt()));

  // getOrders
  getIt.registerFactory<OrderRepo>(() => OrderRepo(getIt()));
  getIt.registerFactory<OrderCubit>(() => OrderCubit(getIt()));

  // categories
  getIt.registerFactory<CategoriesRepo>(() => CategoriesRepo(getIt()));
  getIt.registerFactory<CategoriesCubit>(() => CategoriesCubit(getIt()));

  // profile
  getIt.registerLazySingleton<SegmentRepo>(() => SegmentRepo(getIt()));
  getIt.registerLazySingleton<SegmentCubit>(() => SegmentCubit(getIt()));

  //businessSwitch
  getIt.registerLazySingleton<BusinsessSwitchRepo>(
    () => BusinsessSwitchRepo(getIt()),
  );
  getIt.registerLazySingleton<BusinessSwitchCubit>(
    () => BusinessSwitchCubit(getIt()),
  );

  // dashboard metrics
  getIt.registerFactory<DashboardRepo>(() => DashboardRepo(getIt()));
  getIt.registerFactory<DashboardMetricsCubit>(
    () => DashboardMetricsCubit(getIt()),
  );
}
