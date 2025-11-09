import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/prompting.dart';

class LatihanSoalScreen extends StatefulWidget {
  final List<Map<String, dynamic>> soalList;
  final String? materiName;

  const LatihanSoalScreen({super.key, required this.soalList, this.materiName});

  @override
  State<LatihanSoalScreen> createState() => _LatihanSoalScreenState();
}

class _LatihanSoalScreenState extends State<LatihanSoalScreen> {
  late String soalKategori;
  late int waktuDetik;
  late String isiSoal;
  late String jawabanSiswa = '';
  late Timer? timer;
  bool isLoading = false;
  int incorrectAttempts = 0; // Track incorrect attempts
  int currentQuestionIndex = 0;
  int correctAnswers = 0;

  @override
  void initState() {
    super.initState();

    // Set the first question data
    if (widget.soalList.isNotEmpty) {
      var currentSoal = widget.soalList[currentQuestionIndex];
      soalKategori = currentSoal['soalKategori'] ?? widget.materiName ?? 'Latihan Soal';
      int batasWaktu = currentSoal['batasWaktuPengerjaan'] ?? 180; // Default 3 minutes
      waktuDetik = batasWaktu;
      isiSoal = currentSoal['isiSoal'] ?? '';
    } else {
      soalKategori = widget.materiName ?? 'Latihan Soal';
      waktuDetik = 180;
      isiSoal = 'Tidak ada soal tersedia';
    }

    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (waktuDetik > 0) {
        setState(() {
          waktuDetik--;
        });
      } else {
        // Timer ended, handle timeout by automatically submitting with "Siswa tidak menjawab apapun"
        timer.cancel();
        jawabanSiswa = 'Siswa tidak menjawab apapun';
        kirimJawaban();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatWaktu(int detik) {
    int menit = detik ~/ 60;
    int sisaDetik = detik % 60;
    return '${menit.toString().padLeft(2, '0')}:${sisaDetik.toString().padLeft(2, '0')}';
  }

  void kirimJawaban() async {
    // Stop the timer when submitting an answer
    timer?.cancel();

    setState(() {
      isLoading = true;
    });

    try {
      // Load the .env file

      var currentSoal = widget.soalList[currentQuestionIndex];
      
      // Call the prompting function
      Map<String, dynamic> result = await prompting(
        apiKey: 'AIzaSyAu8KLDdPzccOqSzZjRC6OyopIe7pSuGtk',
        question: isiSoal,
        kunciJawaban: currentSoal['kunciJawaban'] ?? '',
        jawabanSiswa: jawabanSiswa,
      );

      bool isCorrect = result['correctAnswer'] ?? false;
      String explain = result['explain'] ?? '';

      // Update correct answers count
      if (isCorrect) {
        setState(() {
          correctAnswers++;
        });
      } else {
        // If incorrect, increment the counter
        setState(() {
          incorrectAttempts++;
        });
      }

      // Show result modal
      showCorrectAnswerModal(explain, isCorrect);
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      // Restart timer in case of error
      startTimer();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showCorrectAnswerModal(String explanation, bool isCorrect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.clear,
                size: 60,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                explanation,
                style: const TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close modal
                
                // Move to next question or finish quiz
                if (currentQuestionIndex < widget.soalList.length - 1) {
                  // Move to next question
                  setState(() {
                    currentQuestionIndex++;
                    var nextSoal = widget.soalList[currentQuestionIndex];
                    isiSoal = nextSoal['isiSoal'] ?? '';
                    jawabanSiswa = '';
                    
                    // Reset timer for the new question
                    int batasWaktu = nextSoal['batasWaktuPengerjaan'] ?? 180;
                    waktuDetik = batasWaktu;
                  });
                  // Restart the timer for the next question
                  startTimer();
                } else {
                  // All questions answered, show final results
                  showFinalResult();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text('Lanjut'),
            ),
          ],
        );
      },
    );
  }
  
  void showFinalResult() {
    double scorePercentage = (correctAnswers / widget.soalList.length) * 100;
    bool isPassed = scorePercentage >= 80; // 80% or more is passing
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            isPassed ? 'Selamat! 🎉' : 'Perlu Belajar Lagi 😢',
            style: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Anda telah menyelesaikan kuis dengan skor:',
                style: const TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${correctAnswers}/${widget.soalList.length} (${scorePercentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isPassed 
                  ? 'Anda dinyatakan lulus. Pengetahuan Anda tentang materi ini sudah cukup baik.' 
                  : 'Anda belum mencapai skor minimum. Silakan pelajari kembali materi sebelumnya.',
                style: const TextStyle(
                  fontFamily: 'StackSansText',
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close modal
                Navigator.of(context).pop(); // Return to previous screen
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF555555), // Dark gray
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Soal ${currentQuestionIndex + 1}/${widget.soalList.length} • $soalKategori',
          style: const TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              formatWaktu(waktuDetik),
              style: const TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Soal essay
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Soal:',
                      style: const TextStyle(
                        fontFamily: 'StackSansText',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isiSoal,
                      style: const TextStyle(
                        fontFamily: 'StackSansText',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Jawaban:',
                      style: const TextStyle(
                        fontFamily: 'StackSansText',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          jawabanSiswa = value;
                        });
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Tulis jawaban Anda di sini...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      style: const TextStyle(
                        fontFamily: 'StackSansText',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : kirimJawaban,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Kirim',
                        style: TextStyle(
                          fontFamily: 'StackSansText',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}