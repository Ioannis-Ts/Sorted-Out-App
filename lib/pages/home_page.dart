import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

import '../widgets/main_nav_bar.dart';
import '../widgets/tree_progress_button.dart';
import '../widgets/points_cloud.dart';
import '../widgets/events_button.dart';
import '../widgets/barcode_button.dart';
import '../services/stats_store.dart';
import '../widgets/profile_name_button.dart';
import '../widgets/points_collected_bar.dart';

import 'events_page.dart';
import 'recycle_points_page.dart';
import 'barcode_scan_page.dart';
import 'about_page.dart';

class HomePage extends StatelessWidget {
  final String userId;
  final int pointsGoal;
  final int yearA;
  final int yearB;

  const HomePage({
    super.key,
    required this.userId,
    this.pointsGoal = 250,
    this.yearA = 2025,
    this.yearB = 2026,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double treeSize = screenHeight * 0.2;
    final double cloudWidth = screenWidth * 0.80;
    final double cloudHeight = screenHeight * 0.045;
    final double qrSize = screenHeight * 0.09;
    final double navBarHeight = 70.0;

    void showEncouragement({required int before, required int after}) {
      const int goal = 250;

      const String firstMsg = "🎉 First points! Amazing start — keep going!";

      const List<String> impactMsgs = [
        "🌍 Incredible! You’ve reached 250+ points!",
        "🌳 250+ points! Huge positive impact!",
        "✨ You’re past 250 points! Keep leading!",
        "🌟 Superstar recycler! Over 250 points!",
        "💚 The planet thanks you for 250+ points!",
      ];

      const List<String> keepGoingMsgs = [
        "🔥 Nice! Keep going!",
        "💪 Great work — one step at a time!",
        "✨ Awesome progress — don’t stop!",
        "🚀 Let’s go! Every recycle counts!",
        "🌍 You’re making an impact — keep it up!",
        "♻️ Another item saved from the trash!",
        "👏 Well done! Adding up nicely!",
      ];

      String msg;

      if (before == 0 && after > 0) {
        msg = firstMsg;
      } else if (after >= goal) {
        msg = impactMsgs[Random().nextInt(impactMsgs.length)];
      } else {
        msg = keepGoingMsgs[Random().nextInt(keepGoingMsgs.length)];
      }
      print("Before: $before, After: $after. Message Selected: $msg");

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      // Υπολογισμός θέσης για την κορυφή
      // Αφαιρούμε περίπου 130 pixels από το συνολικό ύψος για να κάτσει ψηλά αλλά όχι πάνω στη μπάρα
      final double bottomMargin = screenHeight - 130;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent, // Διφανές για να φανεί μόνο το κουτί μας
          elevation: 0, // Σβήνουμε τη μανίσια σκιά
          duration: const Duration(seconds: 3),
          // Το περιθώριο αυτό το σπρώχνει τέρμα πάνω
          margin: EdgeInsets.only(
            bottom: bottomMargin, 
            left: 40, 
            right: 40
          ),
          content: Container(
            decoration: BoxDecoration(
              color: AppColors.ourYellow, // Το χρώμα που ζήτησες
              borderRadius: BorderRadius.circular(50), // Οβάλ σχήμα (μεγάλη ακτίνα)
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              msg,
              textAlign: TextAlign.center, // Κεντραρισμένο κείμενο
              style: AppTexts.generalBody.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Μαύρα γράμματα για να φαίνονται στο κίτρινο
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content Layer
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, navBarHeight + 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TOP BAR: PROFILE + ABOUT ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ProfileNameButton(userId: userId),

                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AboutPage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.main.withOpacity(0.85),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '?',
                            style: AppTexts.generalTitle.copyWith(
                              fontSize: 22,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // --- STATS TITLE ---
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.outline,
                          width: 1.5,
                        ),
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Points Collected',
                        style: AppTexts.generalBody.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // --- STATS BARS ---
                  StreamBuilder<num>(
                    stream: StatsStore.pointsStream(yearA),
                    builder: (context, snapA) {
                      final pointsA = snapA.data ?? 0;
                      return StreamBuilder<num>(
                        stream: StatsStore.pointsStream(yearB),
                        builder: (context, snapB) {
                          final pointsB = snapB.data ?? 0;
                          final maxPoints = (pointsA > pointsB)
                              ? pointsA
                              : pointsB;
                          return Column(
                            children: [
                              PointsCollectedBar(
                                year: yearA,
                                points: pointsA,
                                maxPoints: maxPoints,
                              ),
                              const SizedBox(height: 8),
                              PointsCollectedBar(
                                year: yearB,
                                points: pointsB,
                                maxPoints: maxPoints,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // --- TREE (tap -> RecyclePointsPage) ---
                  Align(
                    alignment: Alignment.center,
                    child: TreeProgressButton(
                      userId: userId,
                      goal: pointsGoal,
                      size: treeSize,
                      ringWidth: treeSize * 0.05,
                      onTap: () async {
                        final res = await Navigator.of(context)
                            .push<PointsSubmitResult>(
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecyclePointsPage(userId: userId),
                              ),
                            );

                        if (res != null) {
                          showEncouragement(
                            before: res.before,
                            after: res.after,
                          );
                        }
                      },
                    ),
                  ),

                  const Spacer(flex: 2),

                  // --- CLOUD ---
                  Align(
                    alignment: Alignment.center,
                    child: PointsCloud(
                      userId: userId,
                      goal: pointsGoal,
                      minWidth: cloudWidth,
                      height: cloudHeight,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- BUTTONS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      EventsPillButton(
                        height: 52,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EventsPage(userId: userId),
                            ),
                          );
                        },
                      ),
                      QrButton(
                        size: qrSize,
                        onTap: () async {
                          final result = await Navigator.of(context)
                              .push<String>(
                                MaterialPageRoute(
                                  builder: (_) => const BarcodeScanPage(),
                                ),
                              );

                          if (result != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Scanned: $result')),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),

          // Bottom Nav Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MainNavBar(currentIndex: 1, currentUserId: userId),
          ),
        ],
      ),
    );
  }
}
