import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuse_system/core/Routing/app_router.dart';
import 'package:fuse_system/core/Routing/routes.dart';

class FuseApp extends StatelessWidget {
  final AppRouter appRouter;
  const FuseApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 base design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'FUSE',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'SF Pro Display',
            scaffoldBackgroundColor: const Color(0xFFF2F4F7),
          ),
          initialRoute: Routes.checkAuthScreen,
          onGenerateRoute: appRouter.generateRoute,
        );
      },
    );
  }
}
