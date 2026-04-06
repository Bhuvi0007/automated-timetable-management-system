import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// Ensure this path is correct for your project structure
import '../../../core/services/timetable_api_service.dart';

class RegenerationService {
  static Future<Map<String, dynamic>> regenerateTimetable(
      int semesterId) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load Sections
    // Using _ notation for consistency with potential Flutter style guides
    final int sectionCount = prefs.getInt('sections_$semesterId') ?? 2;
    final List<String> sections = List.generate(
      sectionCount,
      (i) => 'Section ${String.fromCharCode(65 + i)}',
    );

    // 2. Load Room Count
    final int numOfRooms = prefs.getInt('rooms_$semesterId') ?? 1;
    final int numOfLabRooms = prefs.getInt('labRooms_$semesterId') ?? 1;

    // 3. Load Course List
    final String? coursesJson = prefs.getString('courses_$semesterId');
    if (coursesJson == null) {
      // Consider logging this error as well
      throw Exception(
          "Regeneration failed: Missing courses data for semester $semesterId (key 'courses_$semesterId')");
    }
    // Use try-catch for robust JSON parsing
    List<dynamic> courseList;
    try {
      courseList = jsonDecode(coursesJson);
    } catch (e) {
      throw Exception(
          "Regeneration failed: Could not parse courses JSON for semester $semesterId. Error: $e");
    }

    // 4. Get Course Sessions Per Week (ensure data format is correct)
    final Map<String, int> courseSessions = {};
    for (final course in courseList) {
      if (course is Map &&
          course.containsKey('code') &&
          course.containsKey('sessionsPerWeek') &&
          course['code'] is String &&
          course['sessionsPerWeek'] is int &&
          course['isLabCourse'] != true) {
        courseSessions[course['code']] = course['sessionsPerWeek'];
      } else if (course is Map) {
        // print("Skipping lab or invalid course in courseSessions: $course");
      }
    }
    final List<String> labCourseCodes = [];
    final Map<String, int> labCourseSessions = {};

    for (final course in courseList) {
      if (course is Map &&
          course['isLabCourse'] == true &&
          course['code'] is String &&
          course['sessionsPerWeek'] is int) {
        labCourseCodes.add(course['code']);
        labCourseSessions[course['code']] = course['sessionsPerWeek'];
      }
    }

    // 5. Load Teacher Mappings
    final String? mappingsJson = prefs.getString('mappings_$semesterId');
    if (mappingsJson == null) {
      throw Exception(
          "Regeneration failed: Missing teacher mappings for semester $semesterId (key 'mappings_$semesterId')");
    }
    List<dynamic> mappingsList;
    try {
      mappingsList = jsonDecode(mappingsJson);
    } catch (e) {
      throw Exception(
          "Regeneration failed: Could not parse mappings JSON for semester $semesterId. Error: $e");
    }

    // ===============================================================
    // 6. ADDED: Load Teachers and create Lookup Map
    //    (Logic adapted from TeacherMapping's _loadTeachersFromPrefs)
    // ===============================================================
    final String? teachersJson =
        prefs.getString('teachers'); // Use the global 'teachers' key
    if (teachersJson == null) {
      // Depending on requirements, you might allow regeneration without names,
      // but throwing an error ensures the API receives expected data.
      throw Exception(
          "Regeneration failed: Missing global teacher data (key 'teachers')");
    }
    List<dynamic> decodedTeachers;
    try {
      decodedTeachers = jsonDecode(teachersJson);
    } catch (e) {
      throw Exception(
          "Regeneration failed: Could not parse global teachers JSON. Error: $e");
    }

    final Map<int, String> teacherIdToNameMap = {};
    for (int i = 0; i < decodedTeachers.length; i++) {
      final teacherData = decodedTeachers[i];
      // Validate the structure of each teacher entry
      if (teacherData is Map &&
          teacherData.containsKey('name') &&
          teacherData['name'] is String) {
        // CRUCIAL ASSUMPTION: Teacher ID is derived from index + 1,
        // matching the logic in TeacherMapping's _loadTeachersFromPrefs.
        // If IDs are stored differently, this needs adjustment.
        final int teacherId = i + 1;
        final String teacherName = teacherData['name'];
        teacherIdToNameMap[teacherId] = teacherName;
      } else {
        // Log invalid entries but continue if possible
        print(
            "Warning: Invalid teacher data format at index $i in 'teachers' list. Skipping entry: $teacherData");
      }
    }
    // ===============================================================
    // END: Load Teachers
    // ===============================================================

    // 7. Build sectionCourseTeacher Map using Teacher Names
    final Map<String, Map<String, String?>> sectionCourseTeacher = {};
    for (final section in sections) {
      // Filter mappings for the current section
      final sectionSpecificMappings =
          mappingsList.where((m) => m is Map && m['section'] == section);

      final Map<String, String?> teacherMap = {};
      for (final m in sectionSpecificMappings) {
        // Defensive check for mapping structure
        if (!m.containsKey('courseId') ||
            !m.containsKey('teacherId') ||
            m['courseId'] is! int ||
            m['teacherId'] is! int) {
          print(
              "Warning: Invalid mapping format found for section $section. Skipping mapping: $m");
          continue;
        }

        final int courseId = m['courseId'];
        final int teacherId = m['teacherId'];

        // Find course code using courseId from the loaded courseList
        final course = courseList.firstWhere(
          (c) => c is Map && c['id'] == courseId,
          orElse: () => null, // Return null if course not found in the list
        );

        // Skip if course details are missing or invalid
        if (course == null ||
            !course.containsKey('code') ||
            course['code'] is! String) {
          print(
              "Warning: Course with ID $courseId not found or missing/invalid 'code' for mapping in section $section. Skipping.");
          continue;
        }
        final String courseCode = course['code'];

        // === Perform Lookup using teacherIdToNameMap ===
        final String? teacherName = teacherIdToNameMap[teacherId];

        if (teacherName == null) {
          print(
              "Warning: Teacher with ID $teacherId (for course $courseCode, section $section) not found in loaded teacher list. Sending null to API.");
          teacherMap[courseCode] = null;
        } else {
          // Successfully found teacher name - use it!
          teacherMap[courseCode] = teacherName;
        }
      }
      // Add the 'None' mapping if required by the API spec
      teacherMap['None'] = null;
      sectionCourseTeacher[section] = teacherMap;
    }

    // Optional: Print the final payload for debugging before sending to API
    // print("Regeneration Service Payload for API:");
    // print(jsonEncode({
    //   'sections': sections,
    //   'num_of_rooms': numOfRooms,
    //   'course_sessions_per_week': courseSessions,
    //   'section_course_teacher':
    //       sectionCourseTeacher, // Should contain names now
    // }));

    // 8. Call API with the correctly structured payload
    final response = await TimetableApiService.generateTimetable(
      sections: sections,
      numOfRooms: numOfRooms,
      numOfLabRooms: numOfLabRooms,
      courseSessions: courseSessions,
      sectionCourseTeacher: sectionCourseTeacher,
      labCourseCodes: labCourseCodes,
      labCourseSessions: labCourseSessions,
    );

    // 9. Handle API Response
    if (response['status'] != 'success') {
      // Include API message in the exception if available
      final message = response['message'] ?? 'Unknown error';
      throw Exception("Failed to regenerate timetable via API: $message");
    }

    // Ensure the response contains the 'timetable' key before returning
    if (!response.containsKey('timetable') || response['timetable'] == null) {
      throw Exception(
          "API response was successful but missing 'timetable' data.");
    }

    // Return the timetable part of the response, casting for safety
    try {
      return response['timetable'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception(
          "API response 'timetable' data has unexpected format. Error: $e");
    }
  }
}
