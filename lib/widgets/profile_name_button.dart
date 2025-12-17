import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_variables.dart';

class ProfileNameButton extends StatelessWidget {
  final String userId;          // Profiles/{userId}
  final VoidCallback? onTap;    // later navigation etc.
  final double avatarSize;

  const ProfileNameButton({
    super.key,
    required this.userId,
    this.onTap,
    this.avatarSize = 54,
  });

  String _initialFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance.collection('Profiles').doc(userId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name = (data?['name'] ?? '').toString().trim();
        final initial = _initialFromName(name);

        // if still loading show a small skeleton-ish widget
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: AppColors.main.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 90,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          );
        }

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: AppColors.main.withOpacity(0.75),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: AppTexts.generalTitle.copyWith(
                    fontSize: 22,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name.isEmpty ? 'Name' : name,
                style: AppTexts.generalTitle.copyWith(
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
