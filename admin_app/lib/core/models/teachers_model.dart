class TeacherModel {
  final String name;
  final String email;
  final String phone;
  final String designation;
  final int maxHoursPerWeek;

  TeacherModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.maxHoursPerWeek,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      designation: json['designation'],
      maxHoursPerWeek: json['maxHoursPerWeek'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'designation': designation,
      'maxHoursPerWeek': maxHoursPerWeek,
    };
  }
}
