import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/core/constants/colors.dart';
import 'package:admin_app/core/constants/routes.dart';
import 'package:admin_app/features/auth/presentation/auth_controller.dart';
import 'package:firedart/firedart.dart';

const apikey = "AIzaSyA6d9ebze3XHM7xBKbUYbmUz-5Q0OBUoO8";
const projectId = "majorproject-c662e";
void main() {
  Firestore.initialize(projectId);
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Timetable Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      initialRoute: Routes.login,
      routes: Routes.routes,
    );
  }
}
