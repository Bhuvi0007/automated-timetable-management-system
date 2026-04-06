import 'package:flutter/material.dart';
import 'package:admin_app/core/widgets/side_panel.dart';
import 'package:admin_app/core/widgets/appbar.dart';
import 'package:admin_app/features/dashboard/presentation/dashboard_page.dart';
import 'package:admin_app/features/teacher/presentation/teacher_page.dart';
// import 'package:admin_app/features/timetable/presentation/timetable_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class AppLayout extends StatefulWidget {
  final int initialIndex;

  const AppLayout({super.key, this.initialIndex = 0});

  @override
  // ignore: library_private_types_in_public_api
  _AppLayoutState createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  late int _selectedIndex;
  late Widget _activePageWidget;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _activePageWidget = _buildContentWidget(widget.initialIndex);
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
// Force rebuild dashboard
      }
      _activePageWidget = _buildContentWidget(index);
    });
  }

  /// Dynamically returns the widget to display
  Widget _buildContentWidget(int index) {
    switch (index) {
      case 0:
        return DashboardPage();
      case 1:
        return const TeacherPage();
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Row(
        children: [
          SidePanel(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemSelected,
          ),
          Expanded(
            child: _activePageWidget,
          ),
        ],
      ),
    );
  }
}
