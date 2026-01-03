import 'package:flutter/material.dart';
import '../theme/app_variables.dart';
import '../widgets/recycle_material_button.dart';
import '../widgets/points_pill.dart';
import '../widgets/submit_pill_button.dart';
import '../widgets/reset_icon_button.dart';
import '../services/profile_points_store.dart';

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

  final Map<String, String> _categoryEmojis = {
    'Plastic': '🧴',
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

  String _getSummaryText() {
    const String prefix = "You recycled:";
    if (_itemCounts.isEmpty) return prefix;

    final parts = <String>[];
    _itemCounts.forEach((key, count) {
      if (count > 0) {
        final emoji = _categoryEmojis[key] ?? '';
        parts.add('${count}x$emoji');
      }
    });

    return "$prefix ${parts.join(' ')}";
  }

  Future<void> _submit() async {
    if (_submitting) return;

    setState(() => _submitting = true);

    try {
      await ProfilePointsStore.addPoints(widget.userId, _sessionPoints);

      if (!mounted) return;

      // ✅ FIX: real back behavior
      Navigator.of(context).pop();
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

          // Back Arrow (Top Left)
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  color: AppColors.textMain,
                  onPressed: () {
                    // ✅ FIX: real back behavior
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                72,
                horizontalPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What did you recycle?',
                    style: AppTexts.generalTitle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a material type:',
                    style: AppTexts.generalBody.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 18),

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
