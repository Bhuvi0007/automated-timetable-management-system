import 'dart:convert';
import 'package:http/http.dart' as http;

class TimetableApiService {
  static const String baseUrl = "http://127.0.0.1:5000";

  static Future<Map<String, dynamic>> generateTimetable({
    required List<String> sections,
    required int numOfRooms,
     required int numOfLabRooms,
    required Map<String, int> courseSessions,
    required Map<String, Map<String, String?>> sectionCourseTeacher,
    required List<String> labCourseCodes,
    required Map<String, int> labCourseSessions,
  }) async {
    final url = Uri.parse("$baseUrl/generate-timetable");

    final body = jsonEncode({
  "sections": sections,
  "num_of_classrooms": numOfRooms,
  "num_of_labrooms": numOfLabRooms,
  "course_req": courseSessions,
  "section_course_teacher": sectionCourseTeacher,
  "all_lab_course_names": labCourseCodes,
  "lab_course_sessions_needed": labCourseSessions,
});


    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          throw Exception("Response is not a valid JSON object.");
        }
      } catch (e) {
        throw Exception("Failed to parse response: $e");
      }
    } else {
      throw Exception(
          "Failed to generate timetable. Status code: ${response.statusCode}");
    }
  }
}
