import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

class SubmitPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const SubmitPillButton({
    super.key,
    this.label = 'SUBMIT',
    required this.onTap,
    this.width = 170,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

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
              color: AppColors.lightGrey.withOpacity(enabled ? 1 : 0.6),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.grey.withOpacity(0.35)),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTexts.generalTitle.copyWith(
                  fontSize: 16,
                  letterSpacing: 1.2,
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
