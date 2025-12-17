import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

class QrButton extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const QrButton({
    super.key,
    this.size = 72,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 1. Add margin to give the shadow space to exist without being clipped
      // The shadow extends downwards and outwards, so we need space around the circle.
      margin: const EdgeInsets.all(12), 
      
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.main,
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
        color: Colors.transparent, // Ensures the ripple effect is visible
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(2), // Adjust padding for the image size inside
            child: Image.asset(
              'assets/images/qr.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
