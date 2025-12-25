import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_variables.dart';

class ProfileNameButton extends StatefulWidget {
  final String userId; // Profiles/{userId}
  final double avatarSize;

  const ProfileNameButton({
    super.key,
    required this.userId,
    this.avatarSize = 54,
  });

  @override
  State<ProfileNameButton> createState() => _ProfileNameButtonState();
}

class _ProfileNameButtonState extends State<ProfileNameButton> {
  final GlobalKey _avatarKey = GlobalKey();

  String _initialFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  void _showLogoutPopup(BuildContext context) async {
    final RenderBox box =
        _avatarKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    final result = await showMenu(
      context: context,
      color: AppColors.ourYellow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height + 6, // 👈 ακριβώς κάτω από το avatar
        position.dx + size.width,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 20),
              const SizedBox(width: 10),
              Text(
                'Logout',
                style: AppTexts.generalBody.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (result == 'logout') {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final docRef =
        FirebaseFirestore.instance.collection('Profiles').doc(widget.userId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name = (data?['name'] ?? '').toString().trim();
        final initial = _initialFromName(name);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: widget.avatarSize,
                height: widget.avatarSize,
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
          onTap: () => _showLogoutPopup(context),
          borderRadius: BorderRadius.circular(999),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔵 Avatar
              Container(
                key: _avatarKey, // 👈 πολύ σημαντικό
                width: widget.avatarSize,
                height: widget.avatarSize,
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

              // 👤 Name
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
