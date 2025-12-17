import 'package:flutter/material.dart';
import '../theme/app_variables.dart';
import '../services/profile_points_store.dart';

class PointsCloud extends StatelessWidget {
  final String userId; // Profiles/{userId}
  final int goal;
  final double height;
  final double minWidth;

  const PointsCloud({
    super.key,
    required this.userId,
    required this.goal,
    this.height = 40,
    this.minWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: ProfilePointsStore.pointsStream(userId),
      builder: (context, snapshot) {
        final points = snapshot.data ?? 0;

        return Align( // να μην “απλώνει” σε όλο το πλάτος
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: minWidth,
              maxWidth: minWidth, // ✅ κλειδώνει το πλάτος
            ),
            child: SizedBox(
              height: height,
              child: CustomPaint(
                painter: _CloudShapePainter(
                  fillColor: AppColors.ourYellow,
                  strokeColor: AppColors.outline, // άλλαξε αν το λες αλλιώς
                  strokeWidth: 2,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Points:',
                        style: AppTexts.generalBody.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$points / $goal',
                        style: AppTexts.generalBody.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        );
      },
    );
  }
}

// --- PAINTER LOGIC (Draws the cloud shape) ---
class _CloudShapePainter extends CustomPainter {
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  _CloudShapePainter({
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintFill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final double cornerRadius = h / 2;
    final double straightWidth = w - (cornerRadius * 2);

    if (straightWidth <= 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(cornerRadius)),
        paintFill,
      );
      return;
    }

    final double bumpWidth = straightWidth / 4;
    final double bumpHeight = h * 0.35;

    path.moveTo(cornerRadius, h);
    path.arcToPoint(Offset(cornerRadius, 0),
        radius: Radius.circular(cornerRadius), clockwise: true);

    for (int i = 0; i < 4; i++) {
      double startX = cornerRadius + (bumpWidth * i);
      double endX = startX + bumpWidth;
      path.quadraticBezierTo(startX + (bumpWidth / 2), 0 - bumpHeight, endX, 0);
    }

    path.arcToPoint(Offset(w - cornerRadius, h),
        radius: Radius.circular(cornerRadius), clockwise: true);

    for (int i = 0; i < 4; i++) {
      double startX = (w - cornerRadius) - (bumpWidth * i);
      double endX = startX - bumpWidth;
      path.quadraticBezierTo(startX - (bumpWidth / 2), h + bumpHeight, endX, h);
    }

    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.15), 6, true);
    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
