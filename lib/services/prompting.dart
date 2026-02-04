import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Fungsi untuk menghapus pembungkus kode seperti ```json atau ```javascript
String removeCodeWrapper(String str) {
  return str
      .replaceAll(RegExp(r'^```(?:javascript|json)\s*', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*```$'), '')
      .trim();
}

/// List of available models in priority order
const List<String> _availableModels = [
  'gemini-3-flash-preview',
  'gemini-2.5-flash',
  'gemini-2.5-flash-lite',
];

/// Fungsi utama untuk memanggil model Gemini dengan fallback ke model lain jika terjadi kuota habis
Future<Map<String, dynamic>> prompting({
  required String apiKey,
  required String question,
  required String kunciJawaban,
  required String jawabanSiswa,
}) async {
  String lastError = '';

  // Try each model in sequence until one succeeds or all fail
  for (String modelId in _availableModels) {
    try {
      // Inisialisasi model
      final model = GenerativeModel(
        model: modelId,
        apiKey: apiKey,
      );

      // Buat prompt seperti di versi JS
      final prompt = '''
Kamu adalah seorang guru yang mengevaluasi jawaban esai yang ahli mengenai Termodinamika.
Terdapat soal mengenai termodinamika berikut: $question.
Kunci jawaban: $kunciJawaban.
Jawaban siswa: $jawabanSiswa.

Berikan:
1. Apakah jawaban siswa benar/salah berdasarkan kunci jawaban tersebut.
2. Alasan singkat mengapa yang ditujukan kepada siswa.

Kembalikan dalam bentuk objek javascript dengan format berikut ini:
{
  "correctAnswer": true/false,
  "explain": "alasan singkat mengapa benar/salah yang ditujukan kepada siswa (NOTE!!!: jangan beritahu muridmu bahwa kamu membandingkan jawabannya dengan kunci jawaban)"
}
''';

      // Kirim ke API
      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      final textResponse = response.text ?? '';

      // Bersihkan output dari code fence
      final clean = removeCodeWrapper(textResponse);

      // Parse JSON dari hasil AI
      final result = jsonDecode(clean);

      // Pastikan hasil berupa map
      if (result is Map<String, dynamic>) {
        // Log which model was used successfully
        print('Successfully used model: $modelId');
        return result;
      } else {
        throw Exception('Format hasil tidak sesuai');
      }
    } catch (e) {
      // Store the error message to potentially return later
      lastError = e.toString();

      // Check if the error is related to quota exceeded
      if (e.toString().toLowerCase().contains('quota') ||
          e.toString().toLowerCase().contains('rate limit') ||
          e.toString().toLowerCase().contains('exceeded')) {
        print('Model $modelId hit quota limit, trying next model...');
        continue; // Try the next model
      } else {
        // If it's a different error, rethrow it
        rethrow;
      }
    }
  }

  // If all models failed due to quota, throw the last error
  throw Exception('All models exceeded quota limits. Last error: $lastError');
}