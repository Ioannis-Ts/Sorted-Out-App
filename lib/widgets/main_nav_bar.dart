import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

class MainNavBar extends StatelessWidget {
  final int? currentIndex;               // 0 = AI, 1 = home, 2 = map. null = κανένα ενεργό
  final ValueChanged<int> onTabSelected;

  const MainNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67,
      decoration: BoxDecoration(
        color: AppColors.main.withOpacity(0.8), // λιγότερο “βαρύ” μωβ
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            index: 0,
            currentIndex: currentIndex,
            onTap: onTabSelected,
            notPressedAsset: 'assets/images/ai_not_pressed.png',
            pressedAsset:    'assets/images/ai_pressed.png',
          ),
          _NavItem(
            index: 1,
            currentIndex: currentIndex,
            onTap: onTabSelected,
            notPressedAsset: 'assets/images/home_not_pressed.png',
            pressedAsset:    'assets/images/home_pressed.png',
          ),
          _NavItem(
            index: 2,
            currentIndex: currentIndex,
            onTap: onTabSelected,
            notPressedAsset: 'assets/images/map_not_pressed.png',
            pressedAsset:    'assets/images/map_pressed.png',
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int? currentIndex;
  final ValueChanged<int> onTap;
  final String notPressedAsset;
  final String pressedAsset;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.notPressedAsset,
    required this.pressedAsset,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentIndex != null && index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Image.asset(
        isActive ? pressedAsset : notPressedAsset,
        width: 64,
        height: 64,
      ),
    );
  }
}
