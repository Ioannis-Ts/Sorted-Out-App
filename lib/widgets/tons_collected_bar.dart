import 'package:flutter/material.dart';
import '../theme/app_variables.dart';

class TonsCollectedBar extends StatelessWidget {
  final int year;
  final num tons;
  final num maxTons;

  const TonsCollectedBar({
    super.key,
    required this.year,
    required this.tons,
    required this.maxTons,
  });

  String _formatNumber(num n) {
    // 35.098.500 style
    final s = n.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write('.');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (maxTons <= 0) ? 0.0 : (tons / maxTons).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          year.toString(),
          style: AppTexts.generalTitle.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 6), // Slightly reduced spacing

        // ✅ Full-width pill, sleeker height
        Container(
          height: 30, // Reduced from 35
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.grey.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12), // Removed large vertical padding
            child: Row(
              children: [
                // bar area
                Expanded(
                  child: SizedBox(
                    height: 8, // ✅ Explicitly thinner bar (the "outer gray area")
                    child: Stack(
                      children: [
                        // background track (full)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        // ✅ fill
                        FractionallySizedBox(
                          widthFactor: ratio,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.main.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Text(
                  _formatNumber(tons),
                  style: AppTexts.generalTitle.copyWith(
                    fontSize: 12, // ✅ Smaller font size
                    fontWeight: FontWeight.w600, // ✅ Boldness ensures visibility
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}