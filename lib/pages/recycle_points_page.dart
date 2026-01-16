import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_variables.dart';
import '../services/profile_points_store.dart';

import '../widgets/recycle_material_button.dart';
import '../widgets/points_pill.dart';
import '../widgets/submit_pill_button.dart';
import '../widgets/reset_icon_button.dart';

class PointsSubmitResult {
  final int before;
  final int after;

  const PointsSubmitResult({required this.before, required this.after});
}

class RecyclePointsPage extends StatefulWidget {
  final String userId;

  const RecyclePointsPage({super.key, required this.userId});

  @override
  State<RecyclePointsPage> createState() => _RecyclePointsPageState();
}

class _RecyclePointsPageState extends State<RecyclePointsPage> {
  int _sessionPoints = 0;
  bool _submitting = false;

  final Map<String, int> _itemCounts = {};

  // ✅ Emoji map (matches your labels)
  static const Map<String, String> _emoji = {
    'Plastic': '🥤',
    'Paper': '📄',
    'Glass': '🍾',
    'Metal': '🥫',
    'Batteries': '🔋',
    'Electronics': '📱',
    'Food': '🍎',
  };

  void _addPoints(String label, int delta) {
    setState(() {
      _sessionPoints += delta;
      _itemCounts[label] = (_itemCounts[label] ?? 0) + 1;
    });
  }

  void _resetPoints() {
    setState(() {
      _sessionPoints = 0;
      _itemCounts.clear();
    });
  }

  // ✅ Summary like: "🥤 x2   📄 x1   🔋 x3"
  String _getSummaryText() {
    if (_itemCounts.isEmpty) return 'No items selected yet.';

    // Keep a stable order (so it doesn't jump around)
    const order = [
      'Plastic',
      'Paper',
      'Glass',
      'Metal',
      'Batteries',
      'Electronics',
      'Food',
    ];

    final parts = <String>[];
    for (final key in order) {
      final count = _itemCounts[key] ?? 0;
      if (count <= 0) continue;
      final em = _emoji[key] ?? '';
      parts.add('$em x$count');
    }

    return parts.isEmpty ? 'No items selected yet.' : parts.join('   ');
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_sessionPoints <= 0) return;

    setState(() => _submitting = true);

    try {
      // ✅ Read BEFORE points
      final profileRef = FirebaseFirestore.instance
          .collection('Profiles')
          .doc(widget.userId);

      final beforeSnap = await profileRef.get();
      final beforePoints =
          (beforeSnap.data()?['totalpoints'] as num?)?.toInt() ?? 0;

      // ✅ Keep your existing logic: add the points
      await ProfilePointsStore.addPoints(widget.userId, _sessionPoints);

      // ✅ Read AFTER points
      final afterSnap = await profileRef.get();
      final afterPoints =
          (afterSnap.data()?['totalpoints'] as num?)?.toInt() ?? beforePoints;

      if (!mounted) return;

      // ✅ Return result to Home (for the pop-up)
      Navigator.of(
        context,
      ).pop(PointsSubmitResult(before: beforePoints, after: afterPoints));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit points: $e')));
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const double horizontalPadding = 22;
    const double gap = 18;

    final double buttonWidth = (size.width - (horizontalPadding * 2) - gap) / 2;

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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Top row: title + reset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recycle Points",
                        style: AppTexts.generalTitle.copyWith(
                          fontSize: 22,
                          color: AppColors.textMain,
                        ),
                      ),
                      ResetIconButton(onTap: _resetPoints),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Points pill (center)
                  Center(child: PointsPill(points: _sessionPoints)),

                  const SizedBox(height: 18),

                  // Buttons grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RecycleMaterialButton(
                        label: 'Plastic',
                        width: buttonWidth,
                        onTap: () => _addPoints('Plastic', AppPoints.plastic),
                      ),
                      RecycleMaterialButton(
                        label: 'Paper',
                        width: buttonWidth,
                        onTap: () => _addPoints('Paper', AppPoints.paper),
                      ),
                    ],
                  ),
                  const SizedBox(height: gap),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RecycleMaterialButton(
                        label: 'Glass',
                        width: buttonWidth,
                        onTap: () => _addPoints('Glass', AppPoints.glass),
                      ),
                      RecycleMaterialButton(
                        label: 'Metal',
                        width: buttonWidth,
                        onTap: () => _addPoints('Metal', AppPoints.metal),
                      ),
                    ],
                  ),
                  const SizedBox(height: gap),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RecycleMaterialButton(
                        label: 'Batteries',
                        width: buttonWidth,
                        onTap: () =>
                            _addPoints('Batteries', AppPoints.batteries),
                      ),
                      RecycleMaterialButton(
                        label: 'Electronics',
                        width: buttonWidth,
                        onTap: () =>
                            _addPoints('Electronics', AppPoints.electronics),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Align(
                    alignment: Alignment.center,
                    child: RecycleMaterialButton(
                      label: 'Food',
                      width: buttonWidth,
                      onTap: () => _addPoints('Food', AppPoints.food),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Summary row (emoji x count)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _getSummaryText(),
                          style: AppTexts.generalBody.copyWith(
                            fontSize: 13,
                            color: AppColors.textMain,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PointsPill(points: _sessionPoints),
                      const SizedBox(width: 8),
                      ResetIconButton(
                        onTap: _resetPoints,
                        height: 40,
                        width: 40,
                      ),
                    ],
                  ),

                  const Spacer(),

                  Align(
                    alignment: Alignment.center,
                    child: SubmitPillButton(
                      onTap: _submitting ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
