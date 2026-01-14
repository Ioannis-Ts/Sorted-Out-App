import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

class PointsSubmitResult {
  final int before;
  final int after;
  final int appliedDelta;

  const PointsSubmitResult({
    required this.before,
    required this.after,
    required this.appliedDelta,
  });
}

class EncouragementToast {
  static final _rng = Random();

  static const String _firstPointsMsg =
      "🎉 First points unlocked! You just started something awesome — keep going!";
  static const String _goalReachedMsg =
      "🌳 YOU DID IT! You reached your goal — amazing work. Keep the streak alive!";

  static const List<String> _encouraging = [
    "🔥 Nice one! Every item counts — keep going!",
    "💪 Great progress! You’re building a real habit!",
    "✨ That’s how it’s done — keep recycling!",
    "🚀 Let’s go! Small actions = big impact!",
    "🌍 You’re helping the planet one step at a time — keep it up!",
  ];

  static void show(
    BuildContext context, {
    required int before,
    required int after,
    required int goal, // typically 250
  }) {
    String message;

    final bool isFirstPoints = before == 0 && after > 0;
    final bool reachedGoal = after >= goal && before < goal;

    if (isFirstPoints) {
      message = _firstPointsMsg;
    } else if (reachedGoal) {
      message = _goalReachedMsg;
    } else {
      message = _encouraging[_rng.nextInt(_encouraging.length)];
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.outline.withOpacity(0.7), width: 1),
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(Icons.eco, color: AppColors.main),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTexts.generalBody.copyWith(
                  fontSize: 14,
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
