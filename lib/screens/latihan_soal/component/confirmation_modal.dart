import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class ConfirmationModal extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationModal({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'StackSansText',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121), // Dark Grey
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(
          fontFamily: 'StackSansText',
          fontSize: 16,
          color: Color(0xFF212121), // Dark Grey
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GFButton(
                  onPressed: onCancel,
                  text: 'Batal',
                  textStyle: const TextStyle(
                    fontFamily: 'StackSansText',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121), // Dark Grey
                  ),
                  color: Color(0xFFFAFAFA), // White/Off-White background
                  shape: GFButtonShape.pills,
                  borderSide: BorderSide(
                    color: Color(0xFF212121), // Dark Grey
                    width: 1,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GFButton(
                  onPressed: onConfirm,
                  text: 'Ya!',
                  textStyle: const TextStyle(
                    fontFamily: 'StackSansText',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  color: Color(0xFFFF6D00), // Energetic Orange
                  shape: GFButtonShape.pills,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}