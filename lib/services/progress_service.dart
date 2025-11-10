import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _progressKey = 'learning_progress';

  // Save the entire dataMateri structure to SharedPreferences
  static Future<void> saveProgress(List<Map<String, dynamic>> dataMateri) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert the dataMateri to a JSON string
    String jsonString = jsonEncode(dataMateri);
    await prefs.setString(_progressKey, jsonString);
  }

  // Load the dataMateri structure from SharedPreferences
  static Future<List<Map<String, dynamic>>?> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_progressKey);
    
    if (jsonString != null) {
      // Convert JSON string back to List<Map<String, dynamic>>
      List<dynamic> decodedList = jsonDecode(jsonString);
      
      // Convert List<dynamic> to List<Map<String, dynamic>>
      List<Map<String, dynamic>> result = [];
      for (var item in decodedList) {
        if (item is Map<String, dynamic>) {
          result.add(item);
        }
      }
      
      return result;
    }
    
    return null;
  }

  // Clear saved progress
  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }
}