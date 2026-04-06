class TimetableSlot {
  final String course;
  final String teacher;

  TimetableSlot({required this.course, required this.teacher});

  factory TimetableSlot.fromJson(Map<String, dynamic> json) {
    return TimetableSlot(
      course: json['course'] ?? '',
      teacher: json['teacher'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Course: $course, Teacher: $teacher';
  }
}

class TimetableModel {
  final Map<String, Map<String, Map<String, TimetableSlot>>> timetable;

  TimetableModel(this.timetable);

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    final timetableJson = json['timetable'] as Map<String, dynamic>? ?? json;

    final result = <String, Map<String, Map<String, TimetableSlot>>>{};

    timetableJson.forEach((section, days) {
      result[section] = {};
      (days as Map<String, dynamic>).forEach((day, slots) {
        result[section]![day] = {};
        (slots as Map<String, dynamic>).forEach((time, slotData) {
          result[section]![day]![time] =
              TimetableSlot.fromJson(slotData as Map<String, dynamic>);
        });
      });
    });

    return TimetableModel(result);
  }
}
