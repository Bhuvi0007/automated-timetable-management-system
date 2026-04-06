import 'package:flutter/material.dart';
import 'package:admin_app/core/constants/colors.dart';

class SemesterCard extends StatelessWidget {
  final int semester;
  final String status;
  final int sections;
  final int courses;
  final bool isConfigured;
  final VoidCallback onConfigureTap;
  final VoidCallback onViewTimetableTap;

  const SemesterCard({
    super.key,
    required this.semester,
    required this.status,
    required this.sections,
    required this.courses,
    required this.isConfigured,
    required this.onConfigureTap,
    required this.onViewTimetableTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if semester is odd or even
    final bool isOdd = semester % 2 == 1;

    // Colors from your design
    final Color oddBorderColor = AppColors.trustworthyNavy;
    final Color evenBorderColor = AppColors.mutedSage;
    final Color configuredColor = AppColors.softTeal;

    // Background colors to mimic your screenshot
    final Color oddBackground = const Color(0xFFF5F9FC);
    final Color evenBackground = const Color(0xFFF2F7ED);

    // Choose colors based on odd/even and configuration status
    final Color borderColor = isConfigured
        ? configuredColor
        : (isOdd ? oddBorderColor : evenBorderColor);
    final Color backgroundColor = isOdd ? oddBackground : evenBackground;
    // Use the border color if not configured, otherwise the "configuredColor"
    // final Color buttonColor = isConfigured ? configuredColor : oddBorderColor;
    // Making only semester 7 card to work. if you want to make all cards work, uncomment the above line and comment the below one.
    final Color buttonColor = isConfigured
        ? configuredColor
        : (semester == 7 ? oddBorderColor : Color.fromARGB(255, 172, 190, 209));

    // Text colors
    const Color titleColor = Color(0xFF2D3B48);
    const Color labelColor = Color(0xFF7A869A);
    const Color valueColor = Color(0xFF2D3B48);

    // Status color changes if configured
    final Color statusColor = isConfigured ? configuredColor : labelColor;

    // Button label & icon
    final String buttonLabel = isConfigured ? 'View Timetable' : 'Configure';
    final IconData buttonIcon =
        isConfigured ? Icons.visibility_outlined : Icons.settings;

    // Display values
    final String sectionsText = sections > 0 ? sections.toString() : "-";
    final String coursesText = courses > 0 ? courses.toString() : "-";

    return Container(
      width: 280,
      height: 220, // Increased height to match your screenshot more closely
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Semester title
                  Text(
                    'Semester $semester',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status text
                  Text(
                    'Status: $status',
                    style: TextStyle(
                      fontSize: 14,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sections/Courses row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                          label: 'Sections',
                          value: sectionsText,
                          labelColor: labelColor,
                          valueColor: valueColor,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          label: 'Courses',
                          value: coursesText,
                          labelColor: labelColor,
                          valueColor: valueColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Divider between content and bottom
          const Divider(
            height: 1,
            thickness: 1,
            color: Color.fromARGB(255, 224, 224, 224),
          ),
          // Small gap so the button doesn't fill the entire bottom
          const SizedBox(height: 8),
          // Bottom button area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44, // Matches the screenshot's button height more closely
              width: double.infinity,
              child: Material(
                color: buttonColor,
                borderRadius: BorderRadius.circular(4),
                child: MouseRegion(
                  cursor: semester == 7
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    // onTap: isConfigured ? onViewTimetableTap : onConfigureTap,
                    // Making only semester 7 card to work. if you want to make all cards work, uncomment the above line and comment the below one.
                    onTap: isConfigured
                        ? onViewTimetableTap
                        : (semester == 7 ? onConfigureTap : null),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          buttonIcon,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          buttonLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Extra spacing below button to match the screenshot's layout
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds a column for "Sections" / "Courses" label + value.
  Widget _buildInfoColumn({
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
