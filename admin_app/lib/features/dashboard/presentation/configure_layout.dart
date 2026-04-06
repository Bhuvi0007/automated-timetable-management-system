import 'package:flutter/material.dart';
import '../../../core/widgets/custom_tabbar.dart';
import '../presentation/semester_configuration/basic_configuration.dart';
import '../presentation/semester_configuration/course_management.dart';
import '../presentation/semester_configuration/teacher_mapping.dart';
import '../../timetable/presentation/timetable_page.dart';
import '../../../core/models/timetable_model.dart';

class ConfigureLayout extends StatefulWidget {
  final int semesterId;
  final String semesterName;
  final VoidCallback onBack;
  final VoidCallback onExitConfigureLayout;

  const ConfigureLayout({
    super.key,
    required this.semesterId,
    required this.semesterName,
    required this.onBack,
    required this.onExitConfigureLayout,
  });

  @override
  State<ConfigureLayout> createState() => _ConfigureLayoutState();
}

class _ConfigureLayoutState extends State<ConfigureLayout> {
  int _selectedTabIndex = 0;
  bool _showTimetable = false;
  int? _numberOfSections;
  String? _selectedSection;
  TimetableModel? _timetableModel;

  final List<String> _tabs = [
    'Basic Configuration',
    'Course Management',
    'Teacher Mapping',
  ];

  @override
  Widget build(BuildContext context) {
    if (_showTimetable &&
        _selectedSection != null &&
        _numberOfSections != null &&
        _timetableModel != null) {
      return TimetablePage(
        semesterId: widget.semesterId,
        numberOfSections: _numberOfSections!,
        selectedSection: _selectedSection!,
        timetable: _timetableModel!,
        onBack: widget.onExitConfigureLayout,
      );
    }

    return Container(
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configure ${widget.semesterName}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Set up sections, courses, and generate timetable',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: CustomTabBar(
                    tabs: _tabs,
                    selectedIndex: _selectedTabIndex,
                    onTabSelected: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return BasicConfiguration(
          semesterId: widget.semesterId,
          onContinue: () => setState(() => _selectedTabIndex = 1),
        );
      case 1:
        return CourseManagement(
          semesterId: widget.semesterId,
          onContinue: () => setState(() => _selectedTabIndex = 2),
        );
      case 2:
        return TeacherMapping(
          semesterId: widget.semesterId,
          onGenerate: (selectedSection, sectionCount, timetableJson) {
            setState(() {
              _selectedSection = selectedSection;
              _numberOfSections = sectionCount;
              _timetableModel =
                  TimetableModel.fromJson({'timetable': timetableJson});
              _showTimetable = true;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
