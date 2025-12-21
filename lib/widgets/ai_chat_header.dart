import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

class AiChatHeader extends StatelessWidget {
  final String title;
  final String iconAsset;

  const AiChatHeader({super.key, required this.title, required this.iconAsset});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          iconAsset, // ✅ ai_pressed.png
          width: 34,
          height: 34,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTexts.generalTitle.copyWith(
              fontSize: 18,
              color: AppColors.textMain,
            ),
          ),
        ),
      ],
    );
  }
}
