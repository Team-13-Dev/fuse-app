import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/DI/dependency_injection.dart';
import 'package:fuse_system/core/Routing/routes.dart';
import 'package:fuse_system/features/ai_chat/UI/screen/ai_chat_screen.dart';
import 'package:fuse_system/features/authentication_check/UI/screen/check_auth_screen.dart';
import 'package:fuse_system/features/categories/UI/screen/categories_screen.dart';
import 'package:fuse_system/features/categories/logic/cubit/categories_cubit.dart';
import 'package:fuse_system/features/customer/UI/screen/customer_screen.dart';
import 'package:fuse_system/features/customer/logic/cubit/customer_cubit.dart';
import 'package:fuse_system/features/dashboard/UI/screen/dashboard_screen.dart';
import 'package:fuse_system/features/dashboard/logic/cubit/dashboard_metrics_cubit.dart';
import 'package:fuse_system/features/login/UI/screen/login_screen.dart';
import 'package:fuse_system/features/login/logic/cubit/login_cubit.dart';
import 'package:fuse_system/features/order/UI/screen/orders_screen.dart';
import 'package:fuse_system/features/order/logic/cubit/order_cubit.dart';
import 'package:fuse_system/features/product/UI/screen/product_screen.dart';
import 'package:fuse_system/features/product/logic/cubit/product_cubit.dart';
import 'package:fuse_system/features/sign_up/UI/screen/sign_up_screen.dart';
import 'package:fuse_system/features/sign_up/logic/cubit/signup_cubit.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.signUpScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<SignupCubit>(),
            child: const SignUpScreen(),
          ),
        );

      case Routes.productScreen:
        // return MaterialPageRoute(builder: (_) => const ProductScreen());
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<ProductCubit>()..getProducts(),
            child: const ProductsScreen(),
          ),
        );

      case Routes.customerScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<CustomerCubit>()..fetchCustomers(),
            child: const CustomersPage(),
          ),
        );

      case Routes.orderScreen:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<OrderCubit>()),
              BlocProvider(
                create: (context) => getIt<CustomerCubit>()..fetchCustomers(),
              ),
              BlocProvider(
                create: (context) => getIt<ProductCubit>()..getProducts(),
              ),
            ],
            child: const OrdersScreen(),
          ),
        );

      case Routes.categoriesScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<CategoriesCubit>()..fetchCategories(),
            child: const CategoriesScreen(),
          ),
        );

      // case Routes.aiChatScreen:
      //   return MaterialPageRoute(builder: (_) => const AIChatScreen());

      case Routes.checkAuthScreen:
        return MaterialPageRoute(builder: (_) => const CheckAuth());
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<LoginCubit>(),
            child: const LoginScreen(),
          ),
        );

      case Routes.dashboardScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<DashboardMetricsCubit>(),
            child: const DashboardScreen(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
