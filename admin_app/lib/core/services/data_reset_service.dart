import 'package:shared_preferences/shared_preferences.dart';

class DataResetService {
  static Future<void> resetAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all SharedPreferences data
      await prefs.clear();

      // Add specific keys to clear if needed
      final keysToRemove = [
        // 'teachers',
        'sections_', // Will be removed with wildcard
        'courses_', // Will be removed with wildcard
        'rooms_', // Will be removed with wildcard
        'mappings_', // Will be removed with wildcard
      ];

      // Remove all keys that start with these prefixes
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (keysToRemove.any((prefix) => key.startsWith(prefix))) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error resetting app data: $e');
      rethrow;
    }
  }
}
