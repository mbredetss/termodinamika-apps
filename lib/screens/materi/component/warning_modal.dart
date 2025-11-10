import 'package:flutter/material.dart';

class WarningModal extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const WarningModal({
    Key? key,
    required this.title,
    required this.content,
    this.buttonText = 'OK',
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'StackSansText',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(fontFamily: 'StackSansText', fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: onButtonPressed,
          child: Text(
            buttonText,
            style: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}