import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // 1. Add this import
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
    final enabled = onTap != null;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(enabled ? 1 : 0.6),
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
          // 2. Wrap the onTap logic to play sound first
          onTap: enabled
              ? () async {
                  // Play the ping sound
                  final player = AudioPlayer();
                  // Ensure your file is at assets/sounds/ping.mp3
                  await player.play(AssetSource('sounds/ping.mp3'));
                  
                  // Run the actual button logic
                  onTap!(); 
                }
              : null,
          child: SizedBox(
            width: width,
            height: height,
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