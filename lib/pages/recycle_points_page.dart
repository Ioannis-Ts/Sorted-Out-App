import 'package:flutter/material.dart';
import '../theme/app_variables.dart';
import '../widgets/main_nav_bar.dart';
import '../widgets/recycle_material_button.dart';
import '../widgets/points_pill.dart';
import '../widgets/submit_pill_button.dart';
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

  void _addPoints(int delta) {
    setState(() => _sessionPoints += delta);
  }

  Future<void> _submit() async {
    if (_submitting) return;

    setState(() => _submitting = true);

    try {
      // IMPORTANT: your existing store writes to Profiles/{userId}.totalpoints
      await ProfilePointsStore.addPoints(widget.userId, _sessionPoints);

      if (!mounted) return;
      Navigator.of(context).pop(); // back to HomePage
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

    // Layout like your screenshot: 2 columns + a centered "Food" button
    const double horizontalPadding = 22;
    const double gap = 18;

    final double buttonWidth = (size.width - (horizontalPadding * 2) - gap) / 2;

    return Scaffold(
      body: Stack(
        children: [
          // Background (same approach as HomePage)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                22,
                horizontalPadding,
                120, // space for navbar
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

                  // Buttons grid (manual rows to match screenshot)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RecycleMaterialButton(
                        label: 'Plastic',
                        width: buttonWidth,
                        onTap: () => _addPoints(AppPoints.plastic),
                      ),
                      RecycleMaterialButton(
                        label: 'Paper',
                        width: buttonWidth,
                        onTap: () => _addPoints(AppPoints.paper),
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
                        onTap: () => _addPoints(AppPoints.glass),
                      ),
                      RecycleMaterialButton(
                        label: 'Metal',
                        width: buttonWidth,
                        onTap: () => _addPoints(AppPoints.metal),
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
                        onTap: () => _addPoints(AppPoints.batteries),
                      ),
                      RecycleMaterialButton(
                        label: 'Electronics',
                        width: buttonWidth,
                        onTap: () => _addPoints(AppPoints.electronics),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.center,
                    child: RecycleMaterialButton(
                      label: 'Food',
                      width: buttonWidth,
                      onTap: () => _addPoints(AppPoints.food),
                    ),
                  ),

                  const SizedBox(height: 26),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "That's great! Here are your points:",
                          style: AppTexts.generalBody.copyWith(
                            fontSize: 14,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      PointsPill(points: _sessionPoints),
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

          // Bottom Nav Bar (keep it like screenshot)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MainNavBar(currentIndex: null), // home highlighted
          ),
        ],
      ),
    );
  }
}
