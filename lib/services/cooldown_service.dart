import 'dart:convert';
import 'storage_service.dart';

class CooldownService {
  static const String _cooldownKey = 'quiz_cooldowns';
  static final _storage = getStorageService(); // Direct access to platform-specific storage

  // Save cooldown data
  static Future<void> saveCooldown(String materiName, DateTime cooldownEndTime) async {
    // Get existing cooldown data
    String? existingData = await _storage.getItem(_cooldownKey);
    Map<String, String> existingCooldowns = {};

    if (existingData != null && existingData.isNotEmpty) {
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

    // Add the new cooldown data
    existingCooldowns[materiName] = cooldownEndTime.toIso8601String();

    // Save back to storage
    String jsonString = jsonEncode(existingCooldowns);
    await _storage.setItem(_cooldownKey, jsonString);
  }

  // Load cooldown data for a specific materi
  static Future<DateTime?> loadCooldown(String materiName) async {
    String? existingData = await _storage.getItem(_cooldownKey);

    if (existingData != null && existingData.isNotEmpty) {
      try {
        Map<String, dynamic> decodedMap = jsonDecode(existingData);
        if (decodedMap.containsKey(materiName)) {
          String? dateString = decodedMap[materiName] as String?;
          if (dateString != null) {
            return DateTime.parse(dateString);
          }
        }
      } catch (e) {
        // If there's an error parsing the JSON, return null
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

  // Clear cooldown for a specific materi
  static Future<void> clearCooldown(String materiName) async {
    String? existingData = await _storage.getItem(_cooldownKey);
    if (existingData != null) {
      try {
        Map<String, dynamic> decodedMap = jsonDecode(existingData);
        decodedMap.remove(materiName);
        String jsonString = jsonEncode(decodedMap);
        await _storage.setItem(_cooldownKey, jsonString);
      } catch (e) {
        // If there's an error parsing, just remove the entire entry
        await _storage.setItem(_cooldownKey, jsonEncode({}));
      }
    }
  }
}