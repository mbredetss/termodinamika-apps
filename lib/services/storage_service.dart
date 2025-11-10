import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;

// This is a wrapper for platform-specific storage
class StorageService {
  static const String _progressKey = 'learning_progress';

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
}