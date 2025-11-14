// platform_storage_service.dart - Platform-specific storage service with static methods

import 'dart:convert';
import 'storage_service.dart';

class StorageService {
  // Static methods for quiz progress management
  static Future<Map<String, dynamic>?> loadQuizProgress(String materiName) async {
    String? data = await _getStorage().getItem('quiz_progress_$materiName');
    if (data != null) {
      try {
        return jsonDecode(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> saveQuizProgress(String materiName, Map<String, dynamic> progress) async {
    String data = jsonEncode(progress);
    await _getStorage().setItem('quiz_progress_$materiName', data);
  }

  static Future<void> clearQuizProgressForMateri(String materiName) async {
    await _getStorage().removeItem('quiz_progress_$materiName');
  }

  // Static methods for general progress management
  static Future<List<Map<String, dynamic>>?> loadProgress() async {
    String? data = await _getStorage().getItem('materi_progress');
    if (data != null) {
      try {
        List<dynamic> decoded = jsonDecode(data);
        List<Map<String, dynamic>> result = [];
        for (var item in decoded) {
          result.add(Map<String, dynamic>.from(item));
        }
        return result;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> saveProgress(List<Map<String, dynamic>> progress) async {
    String data = jsonEncode(progress);
    await _getStorage().setItem('materi_progress', data);
  }

  // Helper method to get storage service instance
  static dynamic _getStorage() => getStorageService();
}