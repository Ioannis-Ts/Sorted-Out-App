import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

class RecycleMaterialButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;

  const RecycleMaterialButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // a little breathing room like QR button
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.main,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: height,
            child: Center(
              child: Text(
                label,
                style: AppTexts.generalTitle.copyWith(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
