import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/materi/components/materi_data.dart';

class ProgressTrackingService {
  static const String _progressKey = 'user_learning_progress';
  static const String _lastAccessedModuleKey = 'last_accessed_module';

  /// Saves the user's progress for a specific sub-materi
  static Future<void> saveSubMateriProgress({
    required String materiName,
    required String subMateriName,
    required bool isCompleted,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? existingProgress = prefs.getString(_progressKey);
    
    Map<String, dynamic> progressData = {};
    if (existingProgress != null) {
      try {
        progressData = jsonDecode(existingProgress);
      } catch (e) {
        // If there's an error parsing, start with empty map
        progressData = {};
      }
    }

    // Update the specific sub-materi progress
    if (!progressData.containsKey(materiName)) {
      progressData[materiName] = {};
    }
    
    progressData[materiName][subMateriName] = isCompleted;

    // Save the updated progress
    await prefs.setString(_progressKey, jsonEncode(progressData));

    // Also save the last accessed module for resuming
    await prefs.setString(_lastAccessedModuleKey, subMateriName);
  }

  /// Gets the progress status for a specific sub-materi
  static Future<bool> getSubMateriProgress({
    required String materiName,
    required String subMateriName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? existingProgress = prefs.getString(_progressKey);
    
    if (existingProgress == null) {
      return false;
    }

    try {
      Map<String, dynamic> progressData = jsonDecode(existingProgress);
      
      if (progressData.containsKey(materiName) && 
          progressData[materiName].containsKey(subMateriName)) {
        return progressData[materiName][subMateriName] ?? false;
      }
    } catch (e) {
      // If there's an error parsing, return false as default
    }

    return false;
  }

  /// Gets all progress data for a specific materi
  static Future<Map<String, bool>> getMateriProgress(String materiName) async {
    final prefs = await SharedPreferences.getInstance();
    String? existingProgress = prefs.getString(_progressKey);
    
    if (existingProgress == null) {
      return {};
    }

    try {
      Map<String, dynamic> progressData = jsonDecode(existingProgress);
      
      if (progressData.containsKey(materiName)) {
        Map<String, bool> materiProgress = {};
        Map<String, dynamic> subMateriProgress = progressData[materiName];

        subMateriProgress.forEach((key, value) {
          materiProgress[key] = value as bool;
        });

        return materiProgress;
      }
    } catch (e) {
      // If there's an error parsing, return empty map as default
    }

    return {};
  }

  /// Gets the last accessed module name
  static Future<String?> getLastAccessedModule() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastAccessedModuleKey);
  }

  /// Gets the next incomplete module for a given materi
  static Future<String?> getNextIncompleteModule(String materiName) async {
    Map<String, bool> progress = await getMateriProgress(materiName);
    
    // Find the corresponding materi in dataMateri
    for (var materi in dataMateri) {
      if (materi['namaMateri'] == materiName) {
        List subMateriList = materi['subMateri'];
        
        for (var subMateri in subMateriList) {
          String subMateriName = subMateri['nama'];
          
          // If this sub-materi hasn't been completed, return it
          if (!(progress[subMateriName] ?? false)) {
            return subMateriName;
          }
        }
      }
    }
    
    // If all modules are completed, return null
    return null;
  }

  /// Gets the first incomplete module across all materi
  static Future<Map<String?, String?>?> getFirstIncompleteModule() async {
    for (var materi in dataMateri) {
      String materiName = materi['namaMateri'];
      Map<String, bool> progress = await getMateriProgress(materiName);
      List subMateriList = materi['subMateri'];
      
      for (var subMateri in subMateriList) {
        String subMateriName = subMateri['nama'];
        
        // If this sub-materi hasn't been completed, return both materi and sub-materi names
        if (!(progress[subMateriName] ?? false)) {
          return {'materiName': materiName, 'subMateriName': subMateriName};
        }
      }
    }
    
    // If all modules are completed, return null
    return null;
  }

  /// Marks a quiz as passed for a specific materi
  static Future<void> markQuizAsPassed(String materiName) async {
    final prefs = await SharedPreferences.getInstance();
    String? existingProgress = prefs.getString(_progressKey);
    
    Map<String, dynamic> progressData = {};
    if (existingProgress != null) {
      try {
        progressData = jsonDecode(existingProgress);
      } catch (e) {
        progressData = {};
      }
    }

    // Mark the materi as completed (this would happen after passing the quiz)
    if (!progressData.containsKey(materiName)) {
      progressData[materiName] = {};
    }
    
    // Mark all sub-materi in this materi as completed
    for (var materi in dataMateri) {
      if (materi['namaMateri'] == materiName) {
        List subMateriList = materi['subMateri'];
        
        for (var subMateri in subMateriList) {
          String subMateriName = subMateri['nama'];
          progressData[materiName][subMateriName] = true;
        }
        
        // Break once we find the correct materi
        break;
      }
    }

    await prefs.setString(_progressKey, jsonEncode(progressData));
  }

  /// Checks if a quiz has been passed for a specific materi
  static Future<bool> isQuizPassed(String materiName) async {
    final prefs = await SharedPreferences.getInstance();
    String? existingProgress = prefs.getString(_progressKey);
    
    if (existingProgress == null) {
      return false;
    }

    try {
      Map<String, dynamic> progressData = jsonDecode(existingProgress);
      
      if (progressData.containsKey(materiName)) {
        Map<String, dynamic> subMateriProgress = progressData[materiName];
        
        // Check if all sub-materi in this materi are marked as completed
        for (var materi in dataMateri) {
          if (materi['namaMateri'] == materiName) {
            List subMateriList = materi['subMateri'];
            
            for (var subMateri in subMateriList) {
              String subMateriName = subMateri['nama'];
              
              if (!(subMateriProgress[subMateriName] ?? false)) {
                return false;
              }
            }
            
            // If all sub-materi are completed, the quiz is considered passed
            return true;
          }
        }
      }
    } catch (e) {
      // If there's an error parsing, return false as default
    }

    return false;
  }

  /// Resets all progress (for testing purposes)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    await prefs.remove(_lastAccessedModuleKey);
  }
}