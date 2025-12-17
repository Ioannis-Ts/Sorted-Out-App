import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

class EventsPillButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double height;
  final EdgeInsets padding;

  const EventsPillButton({
    super.key,
    this.onTap,
    this.height = 52,
    this.padding = const EdgeInsets.symmetric(horizontal: 22),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 1. Margin ensures the shadow isn't clipped by parent widgets
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.main,
        borderRadius: BorderRadius.circular(999), // Fully rounded pill
        boxShadow: [
          // 2. The prominent, darker shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent, // Ensures ripple is visible
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999), // Matches the pill shape
          child: Container(
            height: height,
            padding: padding,
            // Uses Row to center content horizontally
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 22,
                  color: Colors.black87, 
                ),
                const SizedBox(width: 10),
                Text(
                  'EVENTS',
                  style: AppTexts.generalTitle.copyWith(
                    fontSize: 18,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}