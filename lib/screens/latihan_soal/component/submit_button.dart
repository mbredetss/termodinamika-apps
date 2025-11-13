import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:getwidget/getwidget.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const SubmitButton({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: GFButton(
        onPressed: isLoading ? null : onSubmit,
        text: 'Kirim',
        textStyle: const TextStyle(
          fontFamily: 'StackSansText',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        color: isLoading ? Colors.grey : Color(0xFFFF6D00), // Change to grey when loading
        disabledColor: Colors.grey,
        shape: GFButtonShape.pills,
        fullWidthButton: true,
        blockButton: true,
      ),
    );
  }
}