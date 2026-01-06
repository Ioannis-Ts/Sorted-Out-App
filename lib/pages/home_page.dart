import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

import '../widgets/main_nav_bar.dart';
import '../widgets/tree_progress_button.dart';
import '../widgets/points_cloud.dart';
import '../widgets/events_button.dart';
import '../widgets/barcode_button.dart';
import '../services/stats_store.dart';
import '../widgets/profile_name_button.dart';
import '../widgets/tons_collected_bar.dart';

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
    this.yearA = 2024,
    this.yearB = 2025,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double treeSize = screenHeight * 0.27;
    final double cloudWidth = screenWidth * 0.80;
    final double cloudHeight = screenHeight * 0.055;
    final double qrSize = screenHeight * 0.09;
    final double navBarHeight = 90.0;

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
                              color: Colors.white,
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
                        'Tons Collected',
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
                    stream: StatsStore.tonsStream(yearA),
                    builder: (context, snapA) {
                      final tonsA = snapA.data ?? 0;
                      return StreamBuilder<num>(
                        stream: StatsStore.tonsStream(yearB),
                        builder: (context, snapB) {
                          final tonsB = snapB.data ?? 0;
                          final maxTons = (tonsA > tonsB) ? tonsA : tonsB;
                          return Column(
                            children: [
                              TonsCollectedBar(
                                year: yearA,
                                tons: tonsA,
                                maxTons: maxTons,
                              ),
                              const SizedBox(height: 8),
                              TonsCollectedBar(
                                year: yearB,
                                tons: tonsB,
                                maxTons: maxTons,
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
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RecyclePointsPage(userId: userId),
                          ),
                        );
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
                              builder: (_) => const EventsPage(),
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
            // If your MainNavBar does NOT have currentUserId, change to:
            // child: MainNavBar(currentIndex: 1),
          ),
        ],
      ),
    );
  }
}
