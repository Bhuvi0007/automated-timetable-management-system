import 'package:flutter/material.dart';
import 'package:admin_app/core/constants/colors.dart';
import '../presentation/semester_card.dart';
import '../../../../core/models/semester_model.dart';
import '../presentation/configure_layout.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List semesters = List.generate(
    8,
    (index) => SemesterModel(
      semester: index + 1,
      status: 'Not Configured',
      sections: 0,
      courses: 0,
      isConfigured: false,
    ),
  );

  int? _selectedSemesterId;
  String? _selectedSemesterName;

  void _showConfiguration(int semesterId, String semesterName) {
    setState(() {
      _selectedSemesterId = semesterId;
      _selectedSemesterName = semesterName;
    });
  }

  void _goBackToDashboard() {
    setState(() {
      _selectedSemesterId = null;
      _selectedSemesterName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: _selectedSemesterId != null
          ? ConfigureLayout(
              semesterId: _selectedSemesterId!,
              semesterName: _selectedSemesterName!,
              onBack: _goBackToDashboard,
              onExitConfigureLayout: _goBackToDashboard,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Semester Dashboard',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage and generate timetables for all semesters',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildSemesterSection('Odd Semesters', true),
                  const SizedBox(height: 24),
                  _buildSemesterSection('Even Semesters', false),
                ],
              ),
            ),
    );
  }

  Widget _buildSemesterSection(String title, bool isOdd) {
    final items =
        semesters.where((s) => (s.semester % 2 == 1) == isOdd).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900)),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount =
                (constraints.maxWidth / 280).floor().clamp(1, 4);
            return GridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 220,
              ),
              itemBuilder: (context, index) {
                final data = items[index];
                return SemesterCard(
                  semester: data.semester,
                  status: data.status,
                  sections: data.sections,
                  courses: data.courses,
                  isConfigured: data.isConfigured,
                  // onConfigureTap: () => _showConfiguration(
                  //   data.semester,
                  //   'Semester ${data.semester}',
                  // ),
                  // Making only semester 7 card to work. if you want to make all cards work, uncomment the above line and comment the below one.
                  onConfigureTap: data.semester == 7
                      ? () => _showConfiguration(
                          data.semester, 'Semester ${data.semester}')
                      : () {}, // Non-functional tap for other semesters
                  onViewTimetableTap: () {},
                );
              },
            );
          },
        ),
      ],
    );
  }
}
