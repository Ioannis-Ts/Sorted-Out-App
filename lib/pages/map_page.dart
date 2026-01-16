import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/main_nav_bar.dart';
import 'package:geolocator/geolocator.dart';


Future<void> _ensureLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }
}


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.9838, 23.7275),
    zoom: 14.0,
  );

  // --- STATE VARIABLES ---
  Set<Marker> _markers = {};
  List<DocumentSnapshot> _binDocsCache = []; // Stores firestore data
  StreamSubscription? _firestoreSubscription;
  int _iconGeneration = 0;

  // Icons
  BitmapDescriptor? _blueIcon;
  BitmapDescriptor? _yellowIcon;
  BitmapDescriptor? _greyIcon;
  BitmapDescriptor? _brownIcon;
  BitmapDescriptor? _greenIcon;

  // Zoom & Loading State
  double _currentZoom = 14.0;
  bool _iconsLoaded = false;
  bool _isInitLoadDone = false; // Ensures we only load initial icons once

  final String currentUserId =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    // 1. Start listening to Firestore immediately
    _subscribeToBins();
    _ensureLocationPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 2. Load initial icons once we have access to Context (for screen density)
    if (!_isInitLoadDone) {
      _isInitLoadDone = true;
      _updateIconsForZoom(_currentZoom);
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }

  // ==========================================
  // 1. FIRESTORE SUBSCRIPTION
  // ==========================================
  void _subscribeToBins() {
    _firestoreSubscription = FirebaseFirestore.instance
        .collection('bins')
        .snapshots()
        .listen((snapshot) {
      // Update our cache of data
      _binDocsCache = snapshot.docs;
      
      // If icons are ready, draw the markers immediately
      if (_iconsLoaded) {
        _renderMarkers();
      }
    });
  }

  // ==========================================
  // 2. ICON GENERATION (DYNAMIC SIZE)
  // ==========================================
  Future<void> _updateIconsForZoom(double zoom) async {
  if (!mounted) return;

  // 🔒 Create a unique generation ID
  final int generation = ++_iconGeneration;

  final double dpr = MediaQuery.of(context).devicePixelRatio;
  double logicalSize = (zoom * 2.2/22).clamp(10.0, 90.0);
  final int finalSize = (logicalSize * dpr).toInt();

  try {
    final blue   = await _createMarkerIcon('blue', size: finalSize);
    final yellow = await _createMarkerIcon('yellow', size: finalSize);
    final grey   = await _createMarkerIcon('grey', size: finalSize);
    final brown  = await _createMarkerIcon('brown', size: finalSize);
    final green  = await _createMarkerIcon('green', size: finalSize);

    // ❗ Ignore outdated async completions
    if (!mounted || generation != _iconGeneration) return;

    setState(() {
      _blueIcon = blue;
      _yellowIcon = yellow;
      _greyIcon = grey;
      _brownIcon = brown;
      _greenIcon = green;
      _iconsLoaded = true;
    });

    _renderMarkers();
  } catch (e) {
    debugPrint('Icon resize error: $e');
  }
}


  Future<BitmapDescriptor> _createMarkerIcon(String color, {required int size}) async {
    final assetPath = 'assets/images/$color.png';
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: size,
        targetHeight: size,
      );

      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ByteData? resized = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

      if (resized == null) return BitmapDescriptor.defaultMarker;
      
      return BitmapDescriptor.bytes(resized.buffer.asUint8List());
    } catch (e) {
      return BitmapDescriptor.defaultMarker;
    }
  }

  // ==========================================
  // 3. RENDER MARKERS
  // ==========================================
  void _renderMarkers() {
    if (!_iconsLoaded) return;

    final Set<Marker> newMarkers = {};

    for (final doc in _binDocsCache) {
      final data = doc.data() as Map<String, dynamic>;
      final type = data['type'] as String? ?? 'recycle_general';
      
      // HARDCODED NAME
      const name = 'ΚΑΔΟΣ';

      BitmapDescriptor icon;
      String label;

      switch (type) {
        case 'recycle_general':
          icon = _blueIcon!;
          label = 'Γενική Ανακύκλωση';
          break;
        case 'recycle_paper':
          icon = _yellowIcon!;
          label = 'Ανακύκλωση Χαρτιού';
          break;
        case 'recycle_electronics':
          icon = _greyIcon!;
          label = 'Ηλεκτρικές Συσκευές';
          break;
        case 'food':
          icon = _brownIcon!;
          label = 'Οργανικά';
          break;
        case 'trash':
          icon = _greenIcon!;
          label = 'Σκουπίδια';
          break;
        default:
          icon = _blueIcon!;
          label = 'Ανακύκλωση';
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(
            (data['lat'] as num).toDouble(),
            (data['lng'] as num).toDouble(),
          ),
          icon: icon,
          infoWindow: InfoWindow(title: name, snippet: label),
          onTap: () => _showBinOptions(doc.id, name, label),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  // ==========================================
  // 4. CAMERA LOGIC
  // ==========================================
  void _onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  void _onCameraIdle() {
    // When the user stops moving the map, regenerate icons for the new zoom level
    if (_iconsLoaded) {
      _updateIconsForZoom(_currentZoom);
    }
  }

  // ==========================================
  // 5. DIALOGS & UI (Unchanged logic)
  // ==========================================
  void _showAddBinDialog(LatLng position) {
    String selectedType = 'recycle_general';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildTypeBtn(String value, String label, Color activeColor) {
              final bool isSelected = selectedType == value;
              return ElevatedButton(
                onPressed: () {
                  setDialogState(() => selectedType = value);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? activeColor : Colors.grey[300],
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(label),
              );
            }

            return AlertDialog(
              title: const Text('Προσθήκη Κάδου'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Επιλέξτε Τύπο:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        buildTypeBtn('recycle_general', 'Γενική', Colors.blue),
                        buildTypeBtn('recycle_paper', 'Χαρτί', Colors.orange),
                        buildTypeBtn('recycle_electronics', 'Ηλεκτρικές', Colors.grey[700]!),
                        buildTypeBtn('food', 'Οργανικά', Colors.brown),
                        buildTypeBtn('trash', 'Σκουπίδια', Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ακύρωση'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveBin(position, selectedType);
                    Navigator.pop(context);
                  },
                  child: const Text('Προσθήκη'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveBin(LatLng pos, String type) async {
    await FirebaseFirestore.instance.collection('bins').add({
      'lat': pos.latitude,
      'lng': pos.longitude,
      'type': type,
      'name': 'ΚΑΔΟΣ',
      'creatorId': currentUserId,
      'added_at': FieldValue.serverTimestamp(),
    });
  }

  void _showBinOptions(String id, String name, String typeLabel) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Τύπος: $typeLabel"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('bins').doc(id).delete();
                  if (mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text('Διαγραφή Κάδου', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            // Track Camera
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            onLongPress: _showAddBinDialog,
            padding: const EdgeInsets.only(bottom: 80),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MainNavBar(
              currentIndex: 2,
              currentUserId: currentUserId,
            ),
          ),
        ],
      ),
    );
  }
}