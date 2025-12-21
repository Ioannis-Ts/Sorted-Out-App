import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

class RecycleMaterialButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  /// Suggested: pass responsive width from the page
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
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.main,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
