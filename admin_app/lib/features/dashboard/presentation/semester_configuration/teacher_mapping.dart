import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/models/courses_model.dart';
import '../../../../core/services/timetable_api_service.dart';

class HideScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class TeacherMapping extends StatefulWidget {
  final int semesterId;
  final void Function(String selectedSection, int numberOfSections,
      Map<String, dynamic> timetableJson) onGenerate;

  const TeacherMapping({
    super.key,
    required this.semesterId,
    required this.onGenerate,
  });

  @override
  State<TeacherMapping> createState() => _TeacherMappingState();
}

class _TeacherMappingState extends State<TeacherMapping> {
  List<String> _sections = [];
  final List<CourseTeacherMapping> _mappings = [];
  final List<Teacher> _teachers = [];
  final List<Course> _courses = [];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    await _loadSectionsFromPrefs();
    await _loadTeachersFromPrefs();
    await _loadCoursesFromPrefs();
    await _loadMappingsFromPrefs();
  }

  Future<void> _saveMappingsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final mappingsJson = jsonEncode(_mappings.map((m) => m.toJson()).toList());
    await prefs.setString('mappings_${widget.semesterId}', mappingsJson);
  }

  Future<void> _loadMappingsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final mappingsJson = prefs.getString('mappings_${widget.semesterId}');
    if (mappingsJson != null) {
      final decoded = jsonDecode(mappingsJson) as List<dynamic>;
      setState(() {
        _mappings.clear();
        _mappings
            .addAll(decoded.map((json) => CourseTeacherMapping.fromJson(json)));
      });
    }
  }

  Future<void> _loadSectionsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final int sectionCount = prefs.getInt('sections_${widget.semesterId}') ?? 2;
    setState(() {
      _sections = List.generate(
          sectionCount, (i) => 'Section ${String.fromCharCode(65 + i)}');
    });
  }

  Future<void> _loadTeachersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final teachersJson = prefs.getString('teachers');
    if (teachersJson != null) {
      final decoded = jsonDecode(teachersJson) as List<dynamic>;
      setState(() {
        _teachers.clear();
        _teachers.addAll(decoded.asMap().entries.map((entry) {
          final data = entry.value;
          return Teacher(id: entry.key + 1, name: data['name']);
        }));
      });
    }
  }

  Future<void> _loadCoursesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesJson = prefs.getString('courses_${widget.semesterId}');
    if (coursesJson != null) {
      final List<dynamic> coursesList = jsonDecode(coursesJson);
      setState(() {
        _courses.clear();
        _courses.addAll(coursesList.map((json) {
          final course = CourseModel.fromJson(json);
          return Course(
            id: course.id,
            code: course.code,
            name: course.name,
            sessionsPerWeek: course.sessionsPerWeek,
            isLabCourse: course.isLabCourse,
          );
        }).toList());
      });
    }
  } // Helper method to show error dialog if needed

  void _generateTimetable() async {
    // Check for incomplete mappings
    String? errorMessage;

    for (final section in _sections) {
      for (final course in _courses) {
        final mapping = _mappings.firstWhere(
          (m) => m.section == section && m.courseId == course.id,
          orElse: () => CourseTeacherMapping(
            id: -1,
            section: section,
            courseId: course.id,
            teacherId: -1,
          ),
        );

        if (mapping.teacherId == -1) {
          errorMessage =
              "Please assign a teacher for '${course.name}' in $section";
          break;
        }

        final teacherExists = _teachers.any((t) => t.id == mapping.teacherId);
        if (!teacherExists) {
          errorMessage =
              "Invalid teacher assignment for '${course.name}' in $section";
          break;
        }
      }
      if (errorMessage != null) break;
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final int numOfRooms = prefs.getInt('rooms_${widget.semesterId}') ?? 1;
    final int numOfLabRooms =
        prefs.getInt('labRooms_${widget.semesterId}') ?? 1;

    // ✅ Only include non-lab courses
    final courseSessions = {
      for (final course in _courses)
        if (!course.isLabCourse) course.code: course.sessionsPerWeek,
    };

    final labCourseCodes = <String>[];
    final labCourseSessions = <String, int>{};

    for (final course in _courses) {
      if (course.isLabCourse) {
        labCourseCodes.add(course.code);
        labCourseSessions[course.code] = course.sessionsPerWeek;
      }
    }

    final sectionCourseTeacher = <String, Map<String, String?>>{};
    for (final section in _sections) {
      final mappingsInSection = _mappings.where((m) => m.section == section);
      final mappingMap = <String, String?>{};
      for (final mapping in mappingsInSection) {
        final course = _courses.firstWhere(
          (c) => c.id == mapping.courseId,
          orElse: () {
            print("Course with id ${mapping.courseId} not found");
            return Course(
              id: -1,
              code: 'Unknown',
              name: 'Unknown',
              sessionsPerWeek: 0,
              isLabCourse: false,
            );
          },
        );

        final teacher = _teachers.firstWhere(
          (t) => t.id == mapping.teacherId,
          orElse: () {
            print("Teacher with id ${mapping.teacherId} not found");
            return Teacher(id: -1, name: 'Unknown');
          },
        );

        mappingMap[course.code] = teacher.name;
      }
      mappingMap['None'] = null;
      sectionCourseTeacher[section] = mappingMap;
    }

    print(jsonEncode({
      'sections': _sections,
      'num_of_rooms': numOfRooms,
      'numOfLabRooms': numOfLabRooms,
      'course_sessions_per_week': courseSessions,
      'section_course_teacher': sectionCourseTeacher,
      'lab_course_codes': labCourseCodes,
      'lab_course_sessions': labCourseSessions,
    }));

    try {
      final response = await TimetableApiService.generateTimetable(
        sections: _sections,
        numOfRooms: numOfRooms,
        numOfLabRooms: numOfLabRooms,
        courseSessions: courseSessions, // ✅ only normal courses here
        sectionCourseTeacher: sectionCourseTeacher,
        labCourseCodes: labCourseCodes,
        labCourseSessions: labCourseSessions,
      );      if (response['status'] == 'success') {
        final selectedSection = _sections[_selectedTabIndex];
        final timetableData = response['timetable'];
        print('Timetable response structure:');
        print(const JsonEncoder.withIndent('  ').convert(timetableData));
        
        if (timetableData != null) {
          widget.onGenerate(
              selectedSection, _sections.length, timetableData as Map<String, dynamic>);
          print('Timetable generated successfully!');
        } else {
          print('Timetable data is null in the response');
        }
      } else {
        print('Timetable generation failed: ${response['message']}');
      }
    } catch (e) {
      print('Error calling timetable API: $e');
    }
  }

  void _updateTeacherMapping(int courseId, int teacherId) {
    setState(() {
      final section = _sections[_selectedTabIndex];
      final existingIndex = _mappings
          .indexWhere((m) => m.courseId == courseId && m.section == section);

      if (existingIndex != -1) {
        _mappings[existingIndex] = CourseTeacherMapping(
          id: _mappings[existingIndex].id,
          section: section,
          courseId: courseId,
          teacherId: teacherId,
        );
      } else {
        _mappings.add(CourseTeacherMapping(
          id: _mappings.isEmpty ? 1 : _mappings.last.id + 1,
          section: section,
          courseId: courseId,
          teacherId: teacherId,
        ));
      }
      _saveMappingsToPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: HideScrollBehavior(),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teacher Mapping',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Map teachers to courses for each section',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTabs(),
                        const SizedBox(height: 32),
                        ..._courses.map((course) => _CourseCard(
                              course: course,
                              selectedSection: _sections[_selectedTabIndex],
                              mappings: _mappings,
                              teachers: _teachers,
                              onTeacherSelected: (teacherId) =>
                                  _updateTeacherMapping(course.id, teacherId),
                            )),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTabs() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 160.0 * _selectedTabIndex,
            width: 160.0,
            top: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              _sections.length,
              (index) => SizedBox(
                width: 160.0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() => _selectedTabIndex = index),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _selectedTabIndex == index
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _selectedTabIndex == index
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                      child: Text(_sections[index]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Color(0xFFEAEAEA), thickness: 0.7, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _generateTimetable,
                icon: const Icon(Icons.schedule, size: 20, color: Colors.white),
                label: const Text('Generate Timetable',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Mapping Classes
class CourseTeacherMapping {
  final int id;
  final String section;
  final int courseId;
  final int teacherId;

  const CourseTeacherMapping({
    required this.id,
    required this.section,
    required this.courseId,
    required this.teacherId,
  });

  factory CourseTeacherMapping.fromJson(Map<String, dynamic> json) {
    return CourseTeacherMapping(
      id: json['id'],
      section: json['section'],
      courseId: json['courseId'],
      teacherId: json['teacherId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'section': section,
        'courseId': courseId,
        'teacherId': teacherId,
      };
}

class Teacher {
  final int id;
  final String name;

  const Teacher({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Teacher && id == other.id);

  @override
  int get hashCode => id.hashCode;
}

class Course {
  final int id;
  final String code;
  final String name;
  final int sessionsPerWeek;
  final bool isLabCourse;

  const Course({
    required this.id,
    required this.code,
    required this.name,
    required this.sessionsPerWeek,
    required this.isLabCourse,
  });
}

class _CourseCard extends StatefulWidget {
  final Course course;
  final String selectedSection;
  final List<CourseTeacherMapping> mappings;
  final List<Teacher> teachers;
  final Function(int) onTeacherSelected;

  const _CourseCard({
    required this.course,
    required this.selectedSection,
    required this.mappings,
    required this.teachers,
    required this.onTeacherSelected,
  });

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final existingMapping = widget.mappings.firstWhere(
      (m) =>
          m.courseId == widget.course.id && m.section == widget.selectedSection,
      orElse: () => CourseTeacherMapping(
        id: -1,
        section: widget.selectedSection,
        courseId: widget.course.id,
        teacherId: -1,
      ),
    );

    Teacher? selectedTeacher;
    if (existingMapping.teacherId != -1) {
      final match = widget.teachers
          .where((t) => t.id == existingMapping.teacherId)
          .toList();
      if (match.isNotEmpty) {
        selectedTeacher = match.first;
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.grey.shade100 : Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 1,
              spreadRadius: 1,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.course.code}: ${widget.course.name}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.course.sessionsPerWeek} sessions/week • ${widget.course.isLabCourse ? 'Lab' : 'Theory'}',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assign Teacher',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Teacher>(
                        value: selectedTeacher,
                        isExpanded: true,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Select teacher'),
                        ),
                        items: widget.teachers.map((teacher) {
                          return DropdownMenuItem<Teacher>(
                            value: teacher,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(teacher.name),
                            ),
                          );
                        }).toList(),
                        onChanged: (teacher) {
                          if (teacher != null) {
                            widget.onTeacherSelected(teacher.id);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
