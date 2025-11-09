import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Fungsi untuk menghapus pembungkus kode seperti ```json atau ```javascript
String removeCodeWrapper(String str) {
  return str
      .replaceAll(RegExp(r'^```(?:javascript|json)\s*', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*```$'), '')
      .trim();
}

/// Fungsi utama untuk memanggil model Gemini
Future<Map<String, dynamic>> prompting({
  required String apiKey,
  required String question,
  required String kunciJawaban,
  required String jawabanSiswa,
}) async {
  // Inisialisasi model
  final model = GenerativeModel(
    model: 'gemini-2.5-flash',
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
    return result;
  } else {
    throw Exception('Format hasil tidak sesuai');
  }
}