class ApiConstants {
  static const String baseUrl = "https://fuse-eg.vercel.app/api";
  static const String loginEndPoint = "/authService/sign-in";
  static const String signUpEndPoint = "/authService/sign-up";
  static const String signOutEndPoint = "/authService/sign-out";
  static const String productEndPoint = "/products";
  static const String customerEndPoint = "/customers";
  static const String orderEndPoint = "/orders";
  static const String categoriesEndPoint = "/categories";
  static const String profileEndPoint = "/me/context";
  static const String businessSwitchEndPoint = "/businesses/switch";
  static const String dashBoardEndPoint = "/metrics";
  static const String productSegmentation = "/segments/product";
}

class ApiErrors {
  static const String badRequestError = "badRequestError";
  static const String noContent = "noContent";
  static const String forbiddenError = "forbiddenError";
  static const String unauthorizedError = "unauthorizedError";
  static const String notFoundError = "notFoundError";
  static const String conflictError = "conflictError";
  static const String internalServerError = "internalServerError";
  static const String unknownError = "unknownError";
  static const String timeoutError = "timeoutError";
  static const String defaultError = "defaultError";
  static const String cacheError = "cacheError";
  static const String noInternetError = "noInternetError";
  static const String loadingMessage = "loading_message";
  static const String retryAgainMessage = "retry_again_message";
  static const String ok = "Ok";
}
