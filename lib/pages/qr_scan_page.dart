import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/app_variables.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _handled = false; // prevents double triggers
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showResultSheet(String value) async {
    await _controller.stop();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'QR Result',
                style: AppTexts.generalTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 10),
              SelectableText(
                value,
                style: AppTexts.generalBody.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: value));
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.main,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // return result back to HomePage
                        Navigator.pop(ctx);
                        Navigator.pop(context, value);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Use'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  _handled = false;
                  await _controller.start();
                },
                child: const Text('Scan again'),
              ),
            ],
          ),
        );
      },
    );

    // If they dismissed the sheet without scanning again:
    _handled = false;
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (same style as your HomePage)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Scan QR',
                        style: AppTexts.generalTitle.copyWith(fontSize: 18),
                      ),
                      const Spacer(),

                      // Torch
                      IconButton(
                        onPressed: () async {
                          await _controller.toggleTorch();
                          setState(() => _torchOn = !_torchOn);
                        },
                        icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
                      ),

                      // Switch camera
                      IconButton(
                        onPressed: () => _controller.switchCamera(),
                        icon: const Icon(Icons.cameraswitch),
                      ),
                    ],
                  ),
                ),

                // Scanner area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          MobileScanner(
                            controller: _controller,
                            onDetect: (capture) async {
                              if (_handled) return;

                              final barcodes = capture.barcodes;
                              final raw = barcodes.isNotEmpty
                                  ? barcodes.first.rawValue
                                  : null;
                              if (raw == null || raw.trim().isEmpty) return;

                              _handled = true;
                              await _showResultSheet(raw.trim());
                            },
                            errorBuilder: (context, error, child) {
                              return Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Camera error: ${error.errorCode}\n${error.errorDetails ?? ''}',
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),

                          // Overlay (simple scan window)
                          IgnorePointer(
                            child: CustomPaint(
                              painter: _QrOverlayPainter(),
                              child: const SizedBox.expand(),
                            ),
                          ),

                          // Bottom instruction
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.70),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.outline,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  'Align the QR code inside the square',
                                  style: AppTexts.generalBody.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.45);

    // Scan window size (centered)
    final windowWidth = size.width * 0.68;
    final windowHeight = windowWidth;

    final left = (size.width - windowWidth) / 2;
    final top = (size.height - windowHeight) / 2;
    final rect = Rect.fromLTWH(left, top, windowWidth, windowHeight);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(18));

    // Darken everything
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(rrect);

    // Difference: overlay minus window
    final finalPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      cutoutPath,
    );
    canvas.drawPath(finalPath, paint);

    // Border of window
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withOpacity(0.95);

    canvas.drawRRect(rrect, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
