import 'package:flutter/material.dart';
import '../theme/app_variables.dart'; // Adjust import if your path differs

class PointsPill extends StatelessWidget {
  final int points;

  const PointsPill({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Points: $points', // CHANGED: Added "Points: " prefix
          style: const TextStyle(
            color: AppColors.textMain, // Uses your app theme color
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
