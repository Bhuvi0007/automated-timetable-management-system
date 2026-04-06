// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../core/widgets/app_layout.dart';
// import '../../features/timetable/presentation/timetable_page.dart';

// import '../../features/dashboard/presentation/semester_configuration/course_management.dart';
class Routes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String configure = '/configure';
  static const String courseManagement = '/configure/course_management';
  static const String teachers = '/teachers';
  static const String timetable = '/timetable';
  static const String home = '/home';

  static final routes = {
    login: (context) => LoginPage(),
    home: (context) => AppLayout(initialIndex: 0),
    dashboard: (context) => AppLayout(initialIndex: 0),
    teachers: (context) => AppLayout(initialIndex: 1),
  };
}
