import 'package:termodinamika_apps/services/storage_service.dart';

class QuizProgressService {
  /// Load saved quiz progress
  static Future<Map<String, dynamic>?> loadQuizProgress(String materiName) async {
    return await StorageService.loadQuizProgress(materiName);
  }

  /// Save current quiz progress
  static Future<void> saveQuizProgress({
    required String materiName,
    required int currentQuestionIndex,
    required int timeRemaining,
    required String jawabanSiswa,
    required int correctAnswers,
    required int incorrectAttempts,
  }) async {
    Map<String, dynamic> quizProgress = {
      'currentQuestionIndex': currentQuestionIndex,
      'timeRemaining': timeRemaining,
      'jawabanSiswa': jawabanSiswa,
      'correctAnswers': correctAnswers,
      'incorrectAttempts': incorrectAttempts,
      '_expectedEndTime': DateTime.now().add(Duration(seconds: timeRemaining)).toIso8601String(),
    };

    await StorageService.saveQuizProgress(materiName, quizProgress);
  }

  /// Clear saved quiz progress for a specific materi
  static Future<void> clearQuizProgressForMateri(String materiName) async {
    await StorageService.clearQuizProgressForMateri(materiName);
  }
}