class AnswerValidationService {
  /// Validates if the answer field is empty
  /// Returns true if the answer is valid (not empty), false otherwise
  static bool isAnswerValid(String answer) {
    return answer.trim().isNotEmpty;
  }

  /// Returns the validation error message for empty answers
  static String getEmptyAnswerErrorMessage() {
    return 'Harap isi jawaban terlebih dahulu!';
  }
}