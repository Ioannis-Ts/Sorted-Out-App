import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import '../theme/app_variables.dart';

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.all],
  );

  bool _isProcessing = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.start();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _fetchProductData(String barcode) async {
    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'RecycleApp - Android - Version 1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          return data['product'];
        }
      }
    } catch (e) {
      debugPrint('Error fetching product: $e');
    }
    return null;
  }

  /// New Logic: Analyzes tags to find material keywords
  List<String> _detectMaterials(Map<String, dynamic> product) {
    final Set<String> detected = {};

    // 1. Gather all text that might describe packaging
    final List<String> textToSearch = [];

    if (product['packaging_tags'] != null) {
      textToSearch.addAll(List<String>.from(product['packaging_tags']));
    }
    if (product['packaging'] != null) {
      textToSearch.add(product['packaging'].toString());
    }
    if (product['categories_tags'] != null) {
      textToSearch.addAll(List<String>.from(product['categories_tags']));
    }

    // 2. Search for keywords
    final lowerStr = textToSearch.join(' ').toLowerCase();

    // Plastic Keywords
    if (lowerStr.contains('plastic') ||
        lowerStr.contains('pet') ||
        lowerStr.contains('wrapper') ||
        lowerStr.contains('bag') ||
        lowerStr.contains('film')) {
      detected.add('Plastic');
    }

    // Paper Keywords
    if (lowerStr.contains('paper') ||
        lowerStr.contains('cardboard') ||
        lowerStr.contains('carton') ||
        lowerStr.contains('box')) {
      detected.add('Paper');
    }

    // Glass Keywords
    if (lowerStr.contains('glass') ||
        lowerStr.contains('jar') ||
        lowerStr.contains('bottle')) {
      if (lowerStr.contains('glass')) detected.add('Glass');
    }

    // Metal Keywords
    if (lowerStr.contains('metal') ||
        lowerStr.contains('can') ||
        lowerStr.contains('tin') ||
        lowerStr.contains('aluminum')) {
      detected.add('Metal');
    }

    return detected.toList();
  }

  Future<void> _handleScan(String barcode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    await _controller.stop();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final productData = await _fetchProductData(barcode);

    if (mounted) Navigator.of(context).pop();

    if (!mounted) return;
    await _showProductSheet(barcode, productData);

    setState(() => _isProcessing = false);
    await _controller.start();
  }

  Future<void> _showProductSheet(
    String barcode,
    Map<String, dynamic>? product,
  ) async {
    if (!mounted) return;

    final String name = product?['product_name'] ?? 'Unknown Product';
    final String? imageUrl = product?['image_front_small_url'];

    // Use the new detection logic
    final List<String> materials = product != null
        ? _detectMaterials(product)
        : [];

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl == null
                        ? const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTexts.generalTitle.copyWith(fontSize: 18),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Barcode: $barcode',
                          style: AppTexts.generalBody.copyWith(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              Text(
                'Detected Materials',
                style: AppTexts.generalTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),

              if (materials.isNotEmpty)
                Wrap(
                  spacing: 10,
                  children: materials.map((mat) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          _getEmoji(mat),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      label: Text(mat),
                      backgroundColor: AppColors.main.withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: AppColors.main,
                        fontWeight: FontWeight.bold,
                      ),
                      side: BorderSide.none,
                    );
                  }).toList(),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          product == null
                              ? "Product not found in database."
                              : "No packaging info found. Please check the label manually.",
                          style: AppTexts.generalBody.copyWith(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (materials.isNotEmpty)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.main,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context, materials.first);
                        },
                        child: const Text('Add Points'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getEmoji(String material) {
    switch (material) {
      case 'Plastic':
        return '🧴';
      case 'Paper':
        return '📄';
      case 'Glass':
        return '🍾';
      case 'Metal':
        return '🥫';
      default:
        return '♻️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Layer
          MobileScanner(
            controller: _controller,
            fit: BoxFit.cover,
            onDetect: (capture) {
              if (_isProcessing) return;
              final barcodes = capture.barcodes;
              for (final b in barcodes) {
                if (b.rawValue != null && b.rawValue!.isNotEmpty) {
                  _handleScan(b.rawValue!);
                  break;
                }
              }
            },
          ),

          // 2. Overlay Layer (The Dark Box with a hole)
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),

          // 3. UI Layer (Buttons & Text)
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Scan Barcode',
                        style: AppTexts.generalTitle.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          onPressed: () async {
                            await _controller.toggleTorch();
                            setState(() => _torchOn = !_torchOn);
                          },
                          icon: Icon(
                            _torchOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Point camera at a barcode',
                      style: TextStyle(color: Colors.white, fontSize: 14),
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

// --- NEW CLASS: Draws the scanner box overlay ---
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. The dark semi-transparent background color
    final paint = Paint()..color = Colors.black54;

    // 2. Define the size of the clear "Cutout" Window
    // Width = 85% of screen width, Height = 250px (good for barcodes)
    final double windowWidth = size.width * 0.85;
    final double windowHeight = 250;

    final center = size.center(Offset.zero);
    final scanWindowRect = Rect.fromCenter(
      center: center,
      width: windowWidth,
      height: windowHeight,
    );

    // 3. Create the "Hole" in the background
    // We create a path for the whole screen...
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // And a path for the cutout window...
    final windowPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanWindowRect, const Radius.circular(12)),
      );

    // And subtract the window from the background
    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      windowPath,
    );

    canvas.drawPath(path, paint);

    // 4. Draw a white border around the cutout
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanWindowRect, const Radius.circular(12)),
      borderPaint,
    );

    // 5. (Optional) Draw a red "laser" line in the center for effect
    final linePaint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw line from left side of box to right side of box, through the center
    canvas.drawLine(
      Offset(scanWindowRect.left + 20, center.dy),
      Offset(scanWindowRect.right - 20, center.dy),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
