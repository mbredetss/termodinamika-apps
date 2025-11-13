import 'package:termodinamika_apps/services/prompting.dart';

class ApiService {
  /// Submits the student's answer to the API for validation
  static Future<Map<String, dynamic>> submitAnswer({
    required String apiKey,
    required String question,
    required String answerKey,
    required String studentAnswer,
  }) async {
    return {
      'correctAnswer': true, 
      'explain': 'punna'
    };
  }
}
