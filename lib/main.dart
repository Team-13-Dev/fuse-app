import 'package:flutter/material.dart';
import 'package:fuse_system/core/DI/dependency_injection.dart';
import 'package:fuse_system/core/Routing/app_router.dart';
import 'package:fuse_system/fuse_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupGetIt();

  runApp(FuseApp(appRouter: AppRouter()));
}
