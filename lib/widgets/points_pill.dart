import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

class PointsPill extends StatelessWidget {
  final int points;
  final double minWidth;
  final double height;

  const PointsPill({
    super.key,
    required this.points,
    this.minWidth = 60,
    this.height = 34,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.grey.withOpacity(0.35)),
        ),
        child: Center(
          child: Text(
            points.toString(),
            style: AppTexts.generalTitle.copyWith(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
