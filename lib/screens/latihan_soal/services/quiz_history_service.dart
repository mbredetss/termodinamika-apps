import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class QuizHistoryService {
  static const String _historyKey = 'quiz_attempt_history';

  /// Record a quiz attempt with date, percentage, and status
  static Future<void> recordQuizAttempt({
    required String materiName,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Calculate percentage
    double percentage = (correctAnswers / totalQuestions) * 100;
    bool isPassed = percentage >= 80; // 80% or more is passing
    
    // Format the current date and time
    String formattedDateTime = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    
    // Create the attempt record
    Map<String, dynamic> attemptRecord = {
      'materiName': materiName,
      'date': formattedDateTime,
      'percentage': percentage,
      'isPassed': isPassed,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    // Get existing history
    String? existingHistory = prefs.getString(_historyKey);
    List<dynamic> history = [];
    
    if (existingHistory != null) {
      try {
        history = jsonDecode(existingHistory);
      } catch (e) {
        // If there's an error parsing, start with empty list
        history = [];
      }
    }
    
    // Add the new attempt record
    history.add(attemptRecord);
    
    // Sort history by timestamp in descending order (most recent first)
    history.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    
    // Save the updated history
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  /// Get the quiz attempt history for a specific materi
  static Future<List<Map<String, dynamic>>> getQuizHistory(String materiName) async {
    final prefs = await SharedPreferences.getInstance();
    
    String? existingHistory = prefs.getString(_historyKey);
    List<Map<String, dynamic>> history = [];
    
    if (existingHistory != null) {
      try {
        List<dynamic> decodedHistory = jsonDecode(existingHistory);
        
        // Filter history for the specific materi and convert to Map<String, dynamic>
        for (var item in decodedHistory) {
          if (item is Map<String, dynamic> && item['materiName'] == materiName) {
            history.add(item);
          }
        }
      } catch (e) {
        // If there's an error parsing, return empty list
        history = [];
      }
    }
    
    // Return only the 3 most recent attempts
    if (history.length > 3) {
      history = history.take(3).toList();
    }
    
    return history;
  }

  /// Clear all quiz history (for testing purposes)
  static Future<void> clearQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}