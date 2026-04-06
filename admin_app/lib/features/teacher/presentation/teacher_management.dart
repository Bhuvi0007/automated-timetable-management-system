import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/teachers_model.dart';
import 'add_teacher_dialog.dart';

class TeacherManagement extends StatefulWidget {
  const TeacherManagement({super.key});

  @override
  State<TeacherManagement> createState() => _TeacherManagementState();
}

class _TeacherManagementState extends State<TeacherManagement> {
  final List<TeacherModel> _teachers = [];
  List<TeacherModel> _filteredTeachers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeachers();
    _searchController.addListener(_filterTeachers);
  }

  Future<void> _loadTeachers() async {
    final prefs = await SharedPreferences.getInstance();
    final teachersJson = prefs.getString('teachers');
    if (teachersJson != null) {
      final decoded = jsonDecode(teachersJson) as List<dynamic>;
      setState(() {
        _teachers.clear();
        _teachers.addAll(decoded.map((e) => TeacherModel.fromJson(e)));
        _filteredTeachers = List.from(_teachers);
      });
    }
  }

  Future<void> _saveTeachersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_teachers.map((e) => e.toJson()).toList());
    await prefs.setString('teachers', encoded);
  }

  void _filterTeachers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTeachers = List.from(_teachers);
      } else {
        _filteredTeachers = _teachers.where((teacher) {
          return teacher.name.toLowerCase().contains(query) ||
              teacher.email.toLowerCase().contains(query) ||
              teacher.designation.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddTeacherDialog(
          onTeacherAdded: (newTeacher) {
            setState(() {
              _teachers.add(newTeacher);
              _filterTeachers();
            });
            _saveTeachersToPrefs();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Teacher added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        );
      },
    );
  }

  void _editTeacher(TeacherModel teacher) {
    final teacherIndex = _teachers.indexOf(teacher);
    if (teacherIndex != -1) {
      showDialog(
        context: context,
        builder: (context) {
          return AddTeacherDialog(
            teacherToEdit: teacher,
            onTeacherAdded: (updatedTeacher) {
              setState(() {
                _teachers[teacherIndex] = updatedTeacher;
                _filterTeachers();
              });
              _saveTeachersToPrefs();
            },
          );
        },
      );
    }
  }

  void _deleteTeacher(TeacherModel teacher) {
    setState(() {
      _teachers.remove(teacher);
      _filterTeachers();
    });
    _saveTeachersToPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teacher Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Add, edit, and manage teachers in your department',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Department Teachers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add,
                              size: 16, color: Colors.white),
                          label: const Text('Add Teacher'),
                          onPressed: _showAddTeacherDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          hintText: 'Search teachers...',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTableHeader(),
                    _buildTeacherList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          left: BorderSide(color: Colors.grey.shade200),
          right: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('Name')),
          Expanded(flex: 3, child: Text('Email')),
          Expanded(flex: 2, child: Text('Phone')),
          Expanded(flex: 3, child: Text('Designation')),
          Expanded(flex: 2, child: Text('Max Hours/Week')),
          SizedBox(width: 80, child: Text('Actions')),
        ],
      ),
    );
  }

  Widget _buildTeacherList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredTeachers.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final teacher = _filteredTeachers[index];
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                hoverColor: Colors.grey.shade50,
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text(teacher.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500))),
                      Expanded(flex: 3, child: Text(teacher.email)),
                      Expanded(flex: 2, child: Text(teacher.phone)),
                      Expanded(flex: 3, child: Text(teacher.designation)),
                      Expanded(
                          flex: 2,
                          child: Text(teacher.maxHoursPerWeek.toString())),
                      SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(4),
                                  hoverColor:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.edit,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  onTap: () => _editTeacher(teacher),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(4),
                                  hoverColor: Colors.red.withValues(alpha: 0.1),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                  onTap: () => _deleteTeacher(teacher),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
