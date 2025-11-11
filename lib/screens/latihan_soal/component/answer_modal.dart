import 'package:flutter/material.dart';

class AnswerModal extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final VoidCallback onContinue;

  const AnswerModal({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
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
          onPressed: onContinue,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
          child: const Text('Lanjut'),
        ),
      ],
    );
  }
}