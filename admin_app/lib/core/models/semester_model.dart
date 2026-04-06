class SemesterModel {
  final int semester;
  final String status;
  final int sections;
  final int courses;
  final bool isConfigured;

  SemesterModel({
    required this.semester,
    required this.status,
    required this.sections,
    required this.courses,
    required this.isConfigured,
  });

  // Optional: Create from JSON.
  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      semester: json['semester'],
      status: json['status'],
      sections: json['sections'],
      courses: json['courses'],
      isConfigured: json['isConfigured'],
    );
  }

  // Optional: Convert instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'semester': semester,
      'status': status,
      'sections': sections,
      'courses': courses,
      'isConfigured': isConfigured,
    };
  }
}
