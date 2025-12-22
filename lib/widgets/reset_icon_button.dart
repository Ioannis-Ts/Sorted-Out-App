import 'package:flutter/material.dart';

class ResetIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;
  final double width;

  const ResetIconButton({
    super.key,
    required this.onTap,
    this.height = 40, // Standard height to match typical pills
    this.width = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white, // Matches the PointsPill background
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Padding for the icon inside
          child: Image.asset(
            'assets/images/refresh_button.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
