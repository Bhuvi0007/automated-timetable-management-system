class CourseModel {
  final int id;
  final String code;
  final String name;
  final int sessionsPerWeek;
  final bool isLabCourse;

  CourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.sessionsPerWeek,
    required this.isLabCourse,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      sessionsPerWeek: json['sessionsPerWeek'],
      isLabCourse: json['isLabCourse'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'sessionsPerWeek': sessionsPerWeek,
        'isLabCourse': isLabCourse,
      };
}
