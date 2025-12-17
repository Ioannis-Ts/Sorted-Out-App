import 'package:flutter/material.dart';
import '../theme/app_variables.dart';
import '../services/profile_points_store.dart';

class TreeProgressButton extends StatelessWidget {
  final String userId; // must match Profiles/{userId}
  final int goal;      // points needed for 100%
  final double size;
  final double ringWidth;

  const TreeProgressButton({
    super.key,
    required this.userId,
    this.goal = 100,
    this.size = 88,
    this.ringWidth = 7,
  });

  double _progress(int points) {
    if (goal <= 0) return 0;
    return (points / goal).clamp(0.0, 1.0);
  }

  int _treeIndex(double progress) {
    // 9 images => 0..8
    final idx = (progress * 8).floor();
    return idx.clamp(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: ProfilePointsStore.pointsStream(userId),
      builder: (context, snapshot) {
        final points = snapshot.data ?? 0;
        final progress = _progress(points);
        final idx = _treeIndex(progress);
        final asset = 'assets/images/tree$idx.png';

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: size,
            height: size,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return SizedBox(
          width: size,
          height: size,
          child: InkWell(
            borderRadius: BorderRadius.circular(size / 2),
            onTap: () {
              // later: update points here
              // e.g. ProfilePointsStore.addPoints(userId, 5);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // background ring
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: ringWidth,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.lightGrey, // change if your name differs
                    ),
                  ),
                ),

                // progress ring
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: ringWidth,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.main),
                    backgroundColor: Colors.transparent,
                  ),
                ),

                // inner circle + image
                Container(
                  width: size - ringWidth * 2,
                  height: size - ringWidth * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      asset,
                      fit: BoxFit.cover, // fills the circle
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
