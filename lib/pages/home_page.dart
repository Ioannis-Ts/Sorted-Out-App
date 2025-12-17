import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

import '../widgets/main_nav_bar.dart';
import '../widgets/tree_progress_button.dart';
import '../widgets/points_cloud.dart';
import '../widgets/events_button.dart'; // Assuming this is the file for EventsPillButton
import '../widgets/qr_button.dart';
import '../services/stats_store.dart';
import '../widgets/profile_name_button.dart';     
import '../widgets/tons_collected_bar.dart';      

import 'events_page.dart';

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
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Scrollable Content (Dynamic Layout)
          Positioned.fill(
            child: SingleChildScrollView(
              // Add enough bottom padding so the last elements aren't hidden behind the Nav Bar
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 110), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile (top-left)
                  SafeArea( // Keep SafeArea only for the top element if needed, or wrap the whole ListView
                    bottom: false,
                    child: ProfileNameButton(
                      userId: userId,
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Tons Collected title
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outline, width: 1.5),
                        color: Colors.white.withOpacity(0.25),
                      ),
                      child: Text(
                        'Tons Collected',
                        style: AppTexts.generalBody.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Stats Stream
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
                              const SizedBox(height: 12),
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

                  const SizedBox(height: 22),

                  // Tree progress
                  Align(
                    alignment: Alignment.center,
                    child: TreeProgressButton(
                      userId: userId,
                      goal: pointsGoal,
                      size: 180,
                      ringWidth: 10,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Points cloud
                  Align(
                    alignment: Alignment.center,
                    child: PointsCloud(
                      userId: userId,
                      goal: pointsGoal,
                    ),
                  ),

                  const SizedBox(height: 40), 

                  // Bottom row buttons (Now flow dynamically with content)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      EventsPillButton(
                        onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EventsPage(),
                                  ),
                                );
                              },
                      ),
                      QrButton(
                        size: 84,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Nav Bar (Fixed on top of everything)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MainNavBar(
              currentIndex: 1
            ),
          ),
        ],
      ),
    );
  }
}