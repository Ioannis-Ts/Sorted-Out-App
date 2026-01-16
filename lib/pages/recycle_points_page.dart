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

  static const Map<String, String> _emoji = {
    'Plastic': '🥤',
    'Paper': '📄',
    'Glass': '🍾',
    'Metal': '🥫',
    'Batteries': '🔋',
    'Electronics': '📱',
    'Food': '🍎',
  };

  // --- 1. ΠΡΟΣΘΗΚΗ: ΒΟΗΘΗΤΙΚΗ ΣΥΝΑΡΤΗΣΗ ΓΙΑ ΟΜΟΡΦΑ ΜΗΝΥΜΑΤΑ ---
  void _showError(String message, {Color color = Colors.redAccent}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent, // Αόρατο background
        elevation: 0,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.only(
          bottom: 20, // Απόσταση από κάτω
          left: 20,
          right: 20,
        ),
        content: Container(
          decoration: BoxDecoration(
            color: color, // Το χρώμα (π.χ. πορτοκαλί)
            borderRadius: BorderRadius.circular(50), // Οβάλ σχήμα
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
            message,
            textAlign: TextAlign.center,
            style: AppTexts.generalBody.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

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
    if (_itemCounts.isEmpty) return 'No items selected yet.';

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

    // --- 2. ΕΛΕΓΧΟΣ: ΑΝ ΔΕΝ ΕΧΕΙ ΕΠΙΛΕΞΕΙ ΤΙΠΟΤΑ ---
    if (_sessionPoints <= 0) {
      _showError("Please select at least one item!", color: Colors.orange);
      return;
    }

    setState(() => _submitting = true);

    try {
      final profileRef = FirebaseFirestore.instance
          .collection('Profiles')
          .doc(widget.userId);

      final beforeSnap = await profileRef.get();
      final beforePoints =
          (beforeSnap.data()?['totalpoints'] as num?)?.toInt() ?? 0;

      await ProfilePointsStore.addPoints(widget.userId, _sessionPoints);

      // Ενημέρωση γενικών στατιστικών
      await FirebaseFirestore.instance.collection('Stats').doc('2026').set({
        'pointscollected': FieldValue.increment(_sessionPoints),
      }, SetOptions(merge: true));

      final afterSnap = await profileRef.get();
      final afterPoints =
          (afterSnap.data()?['totalpoints'] as num?)?.toInt() ?? beforePoints;

      if (!mounted) return;

      Navigator.of(context).pop(
          PointsSubmitResult(before: beforePoints, after: afterPoints));
    } catch (e) {
      if (!mounted) return;
      // Χρησιμοποιούμε το νέο στυλ και για τα λάθη του συστήματος
      _showError('Failed to submit: $e');
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

                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: AppColors.textMain,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Recycle Points",
                        style: AppTexts.generalTitle.copyWith(
                          fontSize: 22,
                          color: AppColors.textMain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

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

                  // Summary row
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

                  const SizedBox(height: 40),

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