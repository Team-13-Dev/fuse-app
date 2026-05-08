import 'package:dio/dio.dart';
import 'package:fuse_system/core/Networking/api_constants.dart';
import 'package:fuse_system/features/business_switch/data/model/business_switch_request_model.dart';
import 'package:fuse_system/features/business_switch/data/model/business_switch_response_model.dart';
import 'package:fuse_system/features/categories/data/model/add_categories_request_model.dart';
import 'package:fuse_system/features/categories/data/model/add_categories_response_model.dart';
import 'package:fuse_system/features/categories/data/model/categories_response_model.dart';
import 'package:fuse_system/features/customer/data/model/customer_paginated_response_model.dart';
import 'package:fuse_system/features/customer/data/model/customer_request_model.dart';
import 'package:fuse_system/features/customer/data/model/customer_response_model.dart';
import 'package:fuse_system/features/dashboard/data/model/dashboard_response_model.dart';
import 'package:fuse_system/features/dashboard/data/repo/dashboard_repo.dart';
import 'package:fuse_system/features/login/data/model/login_request_body_model.dart';
import 'package:fuse_system/features/login/data/model/login_response_model.dart';
import 'package:fuse_system/features/order/data/model/add_order_request_model.dart';
import 'package:fuse_system/features/order/data/model/add_order_response_model.dart';
import 'package:fuse_system/features/order/data/model/order_response_model.dart';
import 'package:fuse_system/features/product/data/model/product_request_model.dart';
import 'package:fuse_system/features/product/data/model/product_response_model.dart';
import 'package:fuse_system/features/product_segmentation/data/model/product_segmentation_response_model.dart';
import 'package:fuse_system/features/product_segmentation/data/repo/product_segmentaion_repo.dart';
import 'package:fuse_system/features/segment/data/model/segment_context_response_model.dart';
import 'package:fuse_system/features/sign_up/data/model/sign_up_request_model.dart';
import 'package:fuse_system/features/sign_up/data/model/sign_up_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) = _ApiService;

  @POST(ApiConstants.loginEndPoint)
  Future<LoginResponseModel> login(
    @Body() LoginRequestBodyModel loginRequestBodyModel,
  );

  @POST(ApiConstants.signUpEndPoint)
  Future<SignUpResponseModel> signUp(
    @Body() SignUpRequestModel signUpRequestModel,
  );

  @POST(ApiConstants.signOutEndPoint)
  Future<void> signOut();

  // dashboard EndPoint
  @GET(ApiConstants.dashBoardEndPoint)
  Future<DashboardResponseModel> getMetrics();
  // Product EndPoint
  @POST(ApiConstants.productEndPoint)
  Future<ProductResponseModel> createProduct(
    @Body() ProductRequestModel productRequestModel,
  );

  @DELETE("${ApiConstants.productEndPoint}/{id}")
  Future<void> deleteProduct(@Path("id") String id);

  @GET(ApiConstants.productEndPoint)
  Future<ProductsData> getProducts({
    @Query("search") String? search,
    @Query("page") int? page,
    @Query("limit") int? limit,
  });

  // Customer EndPoint
  @GET(ApiConstants.customerEndPoint)
  Future<CustomerPaginatedResponse> getCustomers({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
  });

  @DELETE("${ApiConstants.customerEndPoint}/{id}")
  Future<void> deleteCustomer(@Path("id") String id);

  @POST(ApiConstants.customerEndPoint)
  Future<CustomerResponseModel> createCustomer(
    @Body() CustomerRequestModel customerRequestModel,
  );

  // Order EndPoint
  @GET(ApiConstants.orderEndPoint)
  Future<OrderData> getOrders({
    @Query("search") String? search,
    @Query("limit") int? limit,
    @Query("page") int? page,
  });

  @DELETE("${ApiConstants.orderEndPoint}/{id}")
  Future<void> deleteOrder(@Path("id") String id);

  @POST(ApiConstants.orderEndPoint)
  Future<AddOrderResponseModel> createOrder(
    @Body() AddOrderRequestModel addOrderRequestModel,
  );

  // Categories EndPoint
  @GET(ApiConstants.categoriesEndPoint)
  Future<CategoriesData> getCategories();

  @POST(ApiConstants.categoriesEndPoint)
  Future<AddCategoriesResponseModel> createCategory(
    @Body() AddCategoriesRequestModel addCategoriesRequestModel,
  );

  // Profile
  @GET(ApiConstants.profileEndPoint)
  Future<SegmentContextResponseModel> getSegment();

  // business switch
  @POST(ApiConstants.businessSwitchEndPoint)
  Future<BusinessSwitchResponseModel> businessSwitch(
    @Body() BusinessSwitchRequestModel businessSwitchRequestModel,
  );

  // product segmentation
  @GET(ApiConstants.productSegmentation)
  Future<ProductSegmentationResponseModel> getProductSegmenation();
}
