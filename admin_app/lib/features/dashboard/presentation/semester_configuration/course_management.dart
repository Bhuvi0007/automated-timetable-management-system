import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/models/courses_model.dart';

class CourseManagement extends StatefulWidget {
  final int semesterId;
  final VoidCallback onContinue;

  const CourseManagement({
    super.key,
    required this.semesterId,
    required this.onContinue,
  });

  @override
  State<CourseManagement> createState() => _CourseManagementState();
}

class _CourseManagementState extends State<CourseManagement> {
  final List<CourseModel> _courses = [];
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  int _sessionsPerWeek = 3;
  bool _isLabCourse = false;

  bool _isEditing = false;
  int _editingIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesJson = prefs.getString('courses_${widget.semesterId}');

    if (coursesJson != null) {
      List<dynamic> coursesList = jsonDecode(coursesJson);
      setState(() {
        _courses.clear();
        _courses.addAll(
            coursesList.map((json) => CourseModel.fromJson(json)).toList());
      });
    }
  }

  Future<void> _saveCoursesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> coursesJsonList =
        _courses.map((course) => course.toJson()).toList();
    await prefs.setString(
        'courses_${widget.semesterId}', jsonEncode(coursesJsonList));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addCourse() {
    if (_codeController.text.isNotEmpty && _nameController.text.isNotEmpty) {
      setState(() {
        if (_isEditing && _editingIndex >= 0) {
          _courses[_editingIndex] = CourseModel(
            id: _courses[_editingIndex].id,
            code: _codeController.text,
            name: _nameController.text,
            sessionsPerWeek: _sessionsPerWeek,
            isLabCourse: _isLabCourse,
          );
          _isEditing = false;
          _editingIndex = -1;
        } else {
          _courses.add(
            CourseModel(
              id: _courses.isEmpty ? 1 : _courses.last.id + 1,
              code: _codeController.text,
              name: _nameController.text,
              sessionsPerWeek: _sessionsPerWeek,
              isLabCourse: _isLabCourse,
            ),
          );
        }
        _codeController.clear();
        _nameController.clear();
        _sessionsPerWeek = 3;
        _isLabCourse = false;
      });
    }
  }

  void _editCourse(int index) {
    final course = _courses[index];
    setState(() {
      _isEditing = true;
      _editingIndex = index;
      _codeController.text = course.code;
      _nameController.text = course.name;
      _sessionsPerWeek = course.sessionsPerWeek;
      _isLabCourse = course.isLabCourse;
    });
  }

  Future<void> _saveBasicConfiguration() async {
    await _saveCoursesToPrefs();

    // Print course details to console
    print('\n=== Saved Courses for Semester ${widget.semesterId} ===');
    print('Total Courses: ${_courses.length}');
    for (var i = 0; i < _courses.length; i++) {
      final course = _courses[i];
      print('[Course ${i + 1}]');
      print('  ID: ${course.id}');
      print('  Code: ${course.code}');
      print('  Name: ${course.name}');
      print('  Sessions/Week: ${course.sessionsPerWeek}');
      print('  Lab Course: ${course.isLabCourse ? "Yes (2hr slot)" : "No"}');
    }
    print('===================================\n');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Courses saved for Semester : ${widget.semesterId}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onContinue();
    });
  }

  Widget _buildCounterButton(
      {required IconData icon, VoidCallback? onPressed}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course Management',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Add and manage courses for this semester',
                    style: TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Edit Course' : 'Add New Course',
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Course Code'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _codeController,
                                    decoration: InputDecoration(
                                      hintText: 'e.g., CS101',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Course Name'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      hintText:
                                          'e.g., Introduction to Computer Science',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Sessions/Week'),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildCounterButton(
                                        icon: Icons.remove,
                                        onPressed: () {
                                          if (_sessionsPerWeek > 1) {
                                            setState(() => _sessionsPerWeek--);
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 60,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text('$_sessionsPerWeek',
                                            style:
                                                const TextStyle(fontSize: 16)),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildCounterButton(
                                        icon: Icons.add,
                                        onPressed: () {
                                          setState(() => _sessionsPerWeek++);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Theme(
                          data: ThemeData(
                            checkboxTheme: CheckboxThemeData(
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.primary;
                                }
                                return Colors.grey.shade300;
                              }),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2)),
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isLabCourse,
                                onChanged: (value) {
                                  setState(() {
                                    _isLabCourse = value ?? false;
                                  });
                                },
                              ),
                              const Text(
                                  'Laboratory Course (2 continuous hours)'),
                              Expanded(child: Container()),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _addCourse,
                                    icon: Icon(
                                        _isEditing ? Icons.update : Icons.add,
                                        color: Colors.white),
                                    label: Text(
                                        _isEditing
                                            ? 'Update Course'
                                            : 'Add Course',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  if (_isEditing) ...[
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = false;
                                          _editingIndex = -1;
                                          _codeController.clear();
                                          _nameController.clear();
                                          _sessionsPerWeek = 3;
                                          _isLabCourse = false;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('Code',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('Sessions/Week',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('Type',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('Actions',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _courses.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                          ),
                          itemBuilder: (context, index) {
                            final course = _courses[index];
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  hoverColor:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _editingIndex == index
                                          ? AppColors.primary
                                              .withValues(alpha: 0.05)
                                          : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: Text(course.code),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: Text(course.name),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: Text(course.sessionsPerWeek
                                                  .toString()),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: course.isLabCourse
                                                      ? AppColors.primary
                                                          .withValues(
                                                              alpha: 0.1)
                                                      : Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  course.isLabCourse
                                                      ? 'Laboratory (2 hours)'
                                                      : 'Regular',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: Row(
                                                children: [
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        hoverColor: AppColors
                                                            .primary
                                                            .withValues(
                                                                alpha: 0.1),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300),
                                                          ),
                                                          child: const Icon(
                                                            Icons.edit_outlined,
                                                            color: AppColors
                                                                .primary,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        onTap: () =>
                                                            _editCourse(index),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        hoverColor: Colors.red
                                                            .withValues(
                                                                alpha: 0.1),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300),
                                                          ),
                                                          child: const Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.red,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _courses.removeAt(
                                                                index);
                                                            if (_editingIndex ==
                                                                index) {
                                                              _isEditing =
                                                                  false;
                                                              _editingIndex =
                                                                  -1;
                                                              _codeController
                                                                  .clear();
                                                              _nameController
                                                                  .clear();
                                                              _sessionsPerWeek =
                                                                  3;
                                                              _isLabCourse =
                                                                  false;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              color: Color(0xFFEAEAEA),
              thickness: 0.7,
              height: 1,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveBasicConfiguration,
                  icon: const Icon(
                    Icons.save_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: const Text('Save and Continue',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
