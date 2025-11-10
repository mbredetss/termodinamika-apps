import 'package:flutter/material.dart';

class QuestionDisplay extends StatelessWidget {
  final String questionText;
  final String answerText;
  final ValueChanged<String> onAnswerChanged;
  final TextEditingController? controller;

  const QuestionDisplay({
    Key? key,
    required this.questionText,
    required this.answerText,
    required this.onAnswerChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
              questionText,
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
              controller: controller,
              onChanged: onAnswerChanged,
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
    );
  }
}