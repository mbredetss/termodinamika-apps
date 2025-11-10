import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;

class CooldownService {
  static const String _cooldownKey = 'quiz_cooldowns';

  // Save cooldown data
  static Future<void> saveCooldown(String materiName, DateTime cooldownEndTime) async {
    Map<String, String> cooldownData = { materiName: cooldownEndTime.toIso8601String() };
    
    if (kIsWeb) {
      // For web, use localStorage
      _saveToLocalStorage(cooldownData);
    } else {
      // For mobile, use SharedPreferences
      await _saveToSharedPreferences(cooldownData);
    }
  }

  // Load cooldown data for a specific materi
  static Future<DateTime?> loadCooldown(String materiName) async {
    Map<String, String>? cooldownData;
    
    if (kIsWeb) {
      // For web, use localStorage
      cooldownData = await _loadFromLocalStorage();
    } else {
      // For mobile, use SharedPreferences
      cooldownData = await _loadFromSharedPreferences();
    }
    
    if (cooldownData != null && cooldownData.containsKey(materiName)) {
      try {
        return DateTime.parse(cooldownData[materiName]!);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  // Check if a materi is currently in cooldown
  static Future<bool> isInCooldown(String materiName) async {
    DateTime? cooldownEndTime = await loadCooldown(materiName);
    if (cooldownEndTime != null) {
      return DateTime.now().isBefore(cooldownEndTime);
    }
    return false;
  }

  // Save cooldown data to localStorage for web
  static void _saveToLocalStorage(Map<String, String> cooldownData) {
    // Get existing cooldown data
    String? existingData = web.window.localStorage.getItem(_cooldownKey);
    Map<String, String> existingCooldowns = {};
    
    if (existingData != null) {
      try {
        existingCooldowns = Map<String, String>.from(jsonDecode(existingData));
      } catch (e) {
        // If there's an error parsing, start with empty map
        existingCooldowns = {};
      }
    }
    
    // Merge the new cooldown data
    existingCooldowns.addAll(cooldownData);
    
    // Save back to localStorage
    String jsonString = jsonEncode(existingCooldowns);
    web.window.localStorage.setItem(_cooldownKey, jsonString);
  }

  // Load from localStorage for web
  static Future<Map<String, String>?> _loadFromLocalStorage() async {
    String? jsonString = web.window.localStorage.getItem(_cooldownKey);
    
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        Map<String, dynamic> decodedMap = jsonDecode(jsonString);
        Map<String, String> result = {};
        decodedMap.forEach((key, value) {
          if (value is String) {
            result[key] = value;
          }
        });
        return result;
      } catch (e) {
        // If there's an error parsing the JSON, return null
        return null;
      }
    }
    
    return null;
  }

  // Save cooldown data to SharedPreferences for mobile
  static Future<void> _saveToSharedPreferences(Map<String, String> cooldownData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing cooldown data
    String? existingData = prefs.getString(_cooldownKey);
    Map<String, String> existingCooldowns = {};
    
    if (existingData != null) {
      try {
        Map<String, dynamic> decodedMap = jsonDecode(existingData);
        decodedMap.forEach((key, value) {
          if (value is String) {
            existingCooldowns[key] = value;
          }
        });
      } catch (e) {
        // If there's an error parsing, start with empty map
        existingCooldowns = {};
      }
    }
    
    // Merge the new cooldown data
    existingCooldowns.addAll(cooldownData);
    
    // Save back to SharedPreferences
    String jsonString = jsonEncode(existingCooldowns);
    await prefs.setString(_cooldownKey, jsonString);
  }

  // Load from SharedPreferences for mobile
  static Future<Map<String, String>?> _loadFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_cooldownKey);
    
    if (jsonString != null) {
      try {
        Map<String, dynamic> decodedMap = jsonDecode(jsonString);
        Map<String, String> result = {};
        decodedMap.forEach((key, value) {
          if (value is String) {
            result[key] = value;
          }
        });
        return result;
      } catch (e) {
        // If there's an error parsing the JSON, return null
        return null;
      }
    }
    
    return null;
  }

  // Clear cooldown for a specific materi
  static Future<void> clearCooldown(String materiName) async {
    if (kIsWeb) {
      await _clearFromLocalStorage(materiName);
    } else {
      await _clearFromSharedPreferences(materiName);
    }
  }

  // Clear cooldown from localStorage for web
  static Future<void> _clearFromLocalStorage(String materiName) async {
    String? existingData = web.window.localStorage.getItem(_cooldownKey);
    if (existingData != null) {
      try {
        Map<String, dynamic> decodedMap = jsonDecode(existingData);
        decodedMap.remove(materiName);
        String jsonString = jsonEncode(decodedMap);
        web.window.localStorage.setItem(_cooldownKey, jsonString);
      } catch (e) {
        // If there's an error parsing, just remove the entire entry
        web.window.localStorage.setItem(_cooldownKey, jsonEncode({}));
      }
    }
  }

  // Clear cooldown from SharedPreferences for mobile
  static Future<void> _clearFromSharedPreferences(String materiName) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_cooldownKey);
    
    if (jsonString != null) {
      try {
        Map<String, dynamic> decodedMap = jsonDecode(jsonString);
        decodedMap.remove(materiName);
        String newJsonString = jsonEncode(decodedMap);
        await prefs.setString(_cooldownKey, newJsonString);
      } catch (e) {
        // If there's an error parsing, just remove the entire entry
        await prefs.setString(_cooldownKey, jsonEncode({}));
      }
    }
  }
}