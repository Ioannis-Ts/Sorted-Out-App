import 'package:flutter/material.dart';
import '../theme/app_variables.dart';
import '../pages/home_page.dart'; // <--- Χρειαζόμαστε το HomePage
// import '../pages/ai_assistant_page.dart'; // Αν έχεις τη σελίδα AI, βγάλε το σχόλιο
// import '../pages/map_page.dart'; // Αν έχεις τη σελίδα Map, βγάλε το σχόλιο

class MainNavBar extends StatelessWidget {
  final int? currentIndex; 
  final String currentUserId; // <--- ΝΕΟ: Πρέπει να ξέρουμε ΠΟΙΟΣ είναι ο χρήστης

  const MainNavBar({
    super.key, 
    required this.currentIndex,
    required this.currentUserId, // Υποχρεωτικό πλέον
  });

  void _go(BuildContext context, int index) {
    if (currentIndex != null && currentIndex == index) return;

    // Ειδική διαχείριση για το HOME για να μην πηγαίνει στον Tester
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(userId: currentUserId), // Περνάμε το σωστό ID
        ),
      );
      return;
    }

    // Για τα υπόλοιπα χρησιμοποιούμε τα routes
    final route = switch (index) {
      0 => '/ai',
      2 => '/map',
      _ => '/home',
    };

    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67,
      decoration: BoxDecoration(
        color: AppColors.main.withOpacity(0.8),
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
            onTap: (i) => _go(context, i),
            notPressedAsset: 'assets/images/ai_not_pressed.png',
            pressedAsset: 'assets/images/ai_pressed.png',
          ),
          _NavItem(
            index: 1,
            currentIndex: currentIndex,
            onTap: (i) => _go(context, i),
            notPressedAsset: 'assets/images/home_not_pressed.png',
            pressedAsset: 'assets/images/home_pressed.png',
          ),
          _NavItem(
            index: 2,
            currentIndex: currentIndex,
            onTap: (i) => _go(context, i),
            notPressedAsset: 'assets/images/map_not_pressed.png',
            pressedAsset: 'assets/images/map_pressed.png',
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
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error), // Αν λείπει η εικόνα
      ),
    );
  }
}