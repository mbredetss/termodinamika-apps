import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart'; // Using Get Widget for enhanced styling

class StartQuizButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StartQuizButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: GFButton(
        onPressed: onPressed,
        text: 'Mulai',
        textStyle: const TextStyle(
          fontFamily: 'StackSansText',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        color: const Color(0xFF303F9F), // Deep Indigo color
        shape: GFButtonShape.pills,
        size: GFSize.MEDIUM,
        fullWidthButton: false,
        elevation: 2,
        splashColor: Colors.white.withOpacity(0.2),
      ),
    );
  }
}