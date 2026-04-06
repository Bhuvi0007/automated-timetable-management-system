import 'package:flutter/material.dart';

class TimetableDisplay extends StatelessWidget {
  static const List<String> _defaultDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  static const List<String> _defaultTimes = [
    "8:30-9:30",
    "9:30-10:30",
    "11:00-12:00",
    "12:00-1:00",
    "2:00-3:00",
    "3:00-4:00",
  ];

  final String section;
  final List<List<String>> timetableData;
  final List<List<String>> teacherData;
  final List<String> days;
  final List<String> times;

  const TimetableDisplay({
    super.key,
    required this.section,
    required this.timetableData,
    required this.teacherData,
    List<String>? days,
    List<String>? times,
  })  : days = days ?? _defaultDays,
        times = times ?? _defaultTimes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                ..._buildTimeSlots(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: _buildHeaderCell('Time Slot'),
          ),
          ...days.map((day) => Expanded(child: _buildHeaderCell(day))),
        ],
      ),
    );
  }

  List<Widget> _buildTimeSlots() {
    List<Widget> slots = [];

    for (int i = 0; i < times.length; i++) {
      slots.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 110,
                child: _buildTimeCell(times[i]),
              ),
              ..._buildDayCellsForRow(i),
            ],
          ),
        ),
      );
    }

    return slots;
  }

  List<Widget> _buildDayCellsForRow(int i) {
    List<Widget> cells = [];
    int j = 0;

    while (j < days.length) {
      if (i >= timetableData.length || j >= timetableData[i].length) {
        cells.add(Expanded(child: _buildEmptyCell()));
        j++;
        continue;
      }

      String course = timetableData[i][j];
      bool isLab = _isLabCourse(course);

      // If lab and next column exists, span two day-columns
      if (isLab && j + 1 < days.length) {
        cells.add(
          Expanded(
            flex: 2,
            child: _buildContentCell(i, j, isLab, spanTwoCols: true),
          ),
        );
        j += 2;
      } else {
        cells.add(
          Expanded(
            child: _buildContentCell(i, j, isLab),
          ),
        );
        j++;
      }
    }

    return cells;
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimeCell(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContentCell(int i, int j, bool isLab,
      {bool spanTwoCols = false}) {
    String course = timetableData[i][j];
    String teacher = '';

    if (i < teacherData.length && j < teacherData[i].length) {
      teacher = teacherData[i][j];
    }

    if (course.trim().isEmpty) {
      return _buildEmptyCell();
    }

    return Container(
      height: isLab ? 80 : 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isLab ? Colors.blue[200]! : Colors.grey[300]!,
          width: isLab ? 1.5 : 1,
        ),
        gradient: isLab
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[50]!, Colors.blue[100]!],
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            course,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isLab ? 13 : 14,
              color: isLab ? Colors.blue[900] : Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          if (isLab)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                '2 Hour Lab',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (teacher.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                teacher,
                style: TextStyle(
                  fontSize: 12,
                  color: isLab ? Colors.blue[800] : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCell() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
    );
  }

  bool _isLabCourse(String course) {
    return course.toLowerCase().contains('lab');
  }
}
