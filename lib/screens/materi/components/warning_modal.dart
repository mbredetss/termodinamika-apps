import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart'; // Using Get Widget for enhanced styling

class WarningModal extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const WarningModal({
    super.key,
    required this.title,
    required this.content,
    this.buttonText = 'OK',
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning,
            color: Colors.orange[700],
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: const TextStyle(
          fontFamily: 'StackSansText',
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
      actions: [
        Center(
          child: GFButton(
            onPressed: onButtonPressed,
            text: buttonText,
            textStyle: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            color: const Color(0xFF303F9F), // Deep Indigo color
            shape: GFButtonShape.pills,
            size: GFSize.SMALL,
            elevation: 2,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}