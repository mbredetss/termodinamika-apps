import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;

// This is a wrapper for platform-specific storage
class StorageService {
  static const String _progressKey = 'learning_progress';
  static const String _quizProgressKey = 'quiz_progress';

  // Save the entire dataMateri structure
  static Future<void> saveProgress(List<Map<String, dynamic>> dataMateri) async {
    if (kIsWeb) {
      // For web, use localStorage
      _saveToLocalStorage(dataMateri);
    } else {
      // For mobile, use SharedPreferences
      await _saveToSharedPreferences(dataMateri);
    }
  }

  // Load the dataMateri structure
  static Future<List<Map<String, dynamic>>?> loadProgress() async {
    if (kIsWeb) {
      // For web, use localStorage
      return _loadFromLocalStorage();
    } else {
      // For mobile, use SharedPreferences
      return await _loadFromSharedPreferences();
    }
  }

  // Save to localStorage for web
  static void _saveToLocalStorage(List<Map<String, dynamic>> dataMateri) {
    String jsonString = jsonEncode(dataMateri);
    web.window.localStorage.setItem(_progressKey, jsonString);
  }

  // Load from localStorage for web
  static List<Map<String, dynamic>>? _loadFromLocalStorage() {
    String? jsonString = web.window.localStorage.getItem(_progressKey);
    
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        List<dynamic> decodedList = jsonDecode(jsonString);
        List<Map<String, dynamic>> result = [];
        for (var item in decodedList) {
          if (item is Map<String, dynamic>) {
            result.add(item);
          }
        }
        return result;
      } catch (e) {
        // If there's an error parsing the JSON, return null
        return null;
      }
    }
    
    return null;
  }

  // Save to SharedPreferences for mobile
  static Future<void> _saveToSharedPreferences(List<Map<String, dynamic>> dataMateri) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(dataMateri);
    await prefs.setString(_progressKey, jsonString);
  }

  // Load from SharedPreferences for mobile
  static Future<List<Map<String, dynamic>>?> _loadFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_progressKey);
    
    if (jsonString != null) {
      try {
        List<dynamic> decodedList = jsonDecode(jsonString);
        List<Map<String, dynamic>> result = [];
        for (var item in decodedList) {
          if (item is Map<String, dynamic>) {
            result.add(item);
          }
        }
        return result;
      } catch (e) {
        // If there's an error parsing the JSON, return null
        return null;
      }
    }
    
    return null;
  }

  // Clear saved progress
  static Future<void> clearProgress() async {
    if (kIsWeb) {
      web.window.localStorage.removeItem(_progressKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
    }
  }

  // Save quiz progress data for a specific materi
  static Future<void> saveQuizProgress(String materiName, Map<String, dynamic> quizProgress) async {
    Map<String, dynamic> allQuizProgress = await loadAllQuizProgress() ?? {};
    allQuizProgress[materiName] = quizProgress;
    
    if (kIsWeb) {
      _saveQuizProgressToLocalStorage(allQuizProgress);
    } else {
      await _saveQuizProgressToSharedPreferences(allQuizProgress);
    }
  }

  // Load quiz progress data for a specific materi
  static Future<Map<String, dynamic>?> loadQuizProgress(String materiName) async {
    Map<String, dynamic>? allQuizProgress = await loadAllQuizProgress();
    
    if (allQuizProgress != null && allQuizProgress.containsKey(materiName)) {
      return allQuizProgress[materiName] as Map<String, dynamic>?;
    }
    
    return null;
  }

  // Load all quiz progress data
  static Future<Map<String, dynamic>?> loadAllQuizProgress() async {
    if (kIsWeb) {
      return _loadQuizProgressFromLocalStorage();
    } else {
      return await _loadQuizProgressFromSharedPreferences();
    }
  }

  // Save quiz progress to localStorage for web
  static void _saveQuizProgressToLocalStorage(Map<String, dynamic> allQuizProgress) {
    String jsonString = jsonEncode(allQuizProgress);
    web.window.localStorage.setItem(_quizProgressKey, jsonString);
  }

  // Load quiz progress from localStorage for web
  static Map<String, dynamic>? _loadQuizProgressFromLocalStorage() {
    String? jsonString = web.window.localStorage.getItem(_quizProgressKey);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        Map<String, dynamic> decodedMap = jsonDecode(jsonString);
        return decodedMap;
      } catch (e) {
        // If there's an error parsing the JSON, return null
        return null;
      }
    }

    return null;
  }

  // Save quiz progress to SharedPreferences for mobile
  static Future<void> _saveQuizProgressToSharedPreferences(Map<String, dynamic> allQuizProgress) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(allQuizProgress);
    await prefs.setString(_quizProgressKey, jsonString);
  }

  // Load quiz progress from SharedPreferences for mobile
  static Future<Map<String, dynamic>?> _loadQuizProgressFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_quizProgressKey);

    if (jsonString != null) {
      try {
        Map<String, dynamic> decodedMap = jsonDecode(jsonString);
        return decodedMap;
      } catch (e) {
        // If there's an error parsing the JSON, return null
        return null;
      }
    }

    return null;
  }

  // Clear quiz progress
  static Future<void> clearQuizProgress() async {
    if (kIsWeb) {
      web.window.localStorage.removeItem(_quizProgressKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_quizProgressKey);
    }
  }
  
  // Clear quiz progress for a specific materi
  static Future<void> clearQuizProgressForMateri(String materiName) async {
    Map<String, dynamic>? allQuizProgress = await loadAllQuizProgress();
    
    if (allQuizProgress != null && allQuizProgress.containsKey(materiName)) {
      allQuizProgress.remove(materiName);
      
      if (kIsWeb) {
        _saveQuizProgressToLocalStorage(allQuizProgress);
      } else {
        await _saveQuizProgressToSharedPreferences(allQuizProgress);
      }
    }
  }
}