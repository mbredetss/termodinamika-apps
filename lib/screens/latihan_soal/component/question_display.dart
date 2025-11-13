import 'package:flutter/material.dart';

class QuestionDisplay extends StatelessWidget {
  final String questionText;
  final String answerText;
  final ValueChanged<String> onAnswerChanged;
  final TextEditingController? controller;

  const QuestionDisplay({
    super.key,
    required this.questionText,
    required this.answerText,
    required this.onAnswerChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF1A237E), // Deep Indigo background
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Soal:',
                  style: const TextStyle(
                    fontFamily: 'StackSansText',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFFAFAFA), // White/Off-White background
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFF1A237E), // Deep Indigo border
                    width: 1,
                  ),
                ),
                child: Text(
                  questionText,
                  style: const TextStyle(
                    fontFamily: 'StackSansText',
                    fontSize: 16,
                    color: Color(0xFF212121), // Dark Grey text
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF1A237E), // Deep Indigo background
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Jawaban:',
                  style: const TextStyle(
                    fontFamily: 'StackSansText',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.maxFinite,
                child: TextField(
                  controller: controller,
                  onChanged: onAnswerChanged,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Tulis jawaban Anda di sini...',
                    hintStyle: const TextStyle(
                      fontFamily: 'StackSansText',
                      fontSize: 16,
                      color: Color(0xFF9E9E9E), // Light grey hint text
                    ),
                    filled: true,
                    fillColor: Color(0xFFFAFAFA), // White/Off-White background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFF212121), // Dark Grey border
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFF651FFF), // Electric Violet border when focused
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontFamily: 'StackSansText',
                    fontSize: 16,
                    color: Color(0xFF212121), // Dark Grey text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}