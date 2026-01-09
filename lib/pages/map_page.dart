import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/main_nav_bar.dart';

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

  Set<Marker> _markers = {};

  // Marker icons
  BitmapDescriptor? _blueIcon;
  BitmapDescriptor? _yellowIcon;
  BitmapDescriptor? _greyIcon;
  BitmapDescriptor? _brownIcon;
  BitmapDescriptor? _greenIcon;

  bool _iconsLoaded = false;

  final String currentUserId =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
  }

  // =========================
  // LOAD MARKER ICONS
  // =========================
  Future<void> _loadMarkerIcons() async {
    _blueIcon   = await _createMarkerIcon('blue', size: 30);
    _yellowIcon = await _createMarkerIcon('yellow', size: 30);
    _greyIcon   = await _createMarkerIcon('grey', size: 30);
    _brownIcon  = await _createMarkerIcon('brown', size: 30);
    _greenIcon  = await _createMarkerIcon('green', size: 30);

    setState(() => _iconsLoaded = true);
    _loadBins();
  }

  Future<BitmapDescriptor> _createMarkerIcon(
    String color, {
    int size = 30,
  }) async {
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
      final ByteData? resized =
          await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(resized!.buffer.asUint8List());
    } catch (e) {
      return BitmapDescriptor.defaultMarker;
    }
  }

  // =========================
  // LOAD BINS
  // =========================
  void _loadBins() {
    if (!_iconsLoaded) return;

    FirebaseFirestore.instance
        .collection('bins')
        .snapshots()
        .listen((snapshot) {
      final Set<Marker> newMarkers = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final type = data['type'] as String? ?? 'recycle_general';
        final name = data['name'] ?? 'ΚΑΔΟΣ';

        BitmapDescriptor icon;
        String label;

        switch (type) {
          case 'recycle_general':
            icon = _blueIcon ?? BitmapDescriptor.defaultMarker;
            label = 'Γενική Ανακύκλωση';
            break;
          case 'recycle_paper':
            icon = _yellowIcon ?? BitmapDescriptor.defaultMarker;
            label = 'Ανακύκλωση Χαρτιού';
            break;
          case 'recycle_electronics':
            icon = _greyIcon ?? BitmapDescriptor.defaultMarker;
            label = 'Ηλεκτρικές Συσκευές';
            break;
          case 'food':
            icon = _brownIcon ?? BitmapDescriptor.defaultMarker;
            label = 'Οργανικά';
            break;
          case 'trash':
            icon = _greenIcon ?? BitmapDescriptor.defaultMarker;
            label = 'Σκουπίδια';
            break;
          default:
            icon = _blueIcon ?? BitmapDescriptor.defaultMarker;
            label = 'Ανακύκλωση';
        }

        newMarkers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(
              (data['lat'] as num).toDouble(), 
              (data['lng'] as num).toDouble()
            ),
            icon: icon,
            infoWindow: InfoWindow(title: name, snippet: label),
            onTap: () => _showBinOptions(doc.id, name, label),
          ),
        );
      }

      if (mounted) {
        setState(() => _markers = newMarkers);
      }
    });
  }

  // =========================
  // ADD BIN DIALOG
  // =========================
  void _showAddBinDialog(LatLng position) {
    String selectedType = 'recycle_general'; 
    // ✅ Removed nameController

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            
            Widget buildTypeBtn(String value, String label, Color activeColor) {
              final bool isSelected = selectedType == value;
              return ElevatedButton(
                onPressed: () {
                  setDialogState(() {
                    selectedType = value; 
                  });
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
                    // ✅ Removed TextField for name
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
                    // ✅ Automatically passing 'ΚΑΔΟΣ' instead of controller text
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

  // =========================
  // SAVE BIN
  // =========================
  Future<void> _saveBin(LatLng pos, String type) async {
    await FirebaseFirestore.instance.collection('bins').add({
      'lat': pos.latitude,
      'lng': pos.longitude,
      'type': type,
      'name': 'ΚΑΔΟΣ', // ✅ Hardcoded name
      'creatorId': currentUserId,
      'added_at': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // BIN OPTIONS
  // =========================
  void _showBinOptions(String id, String name, String typeLabel) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Τύπος: $typeLabel"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('bins')
                      .doc(id)
                      .delete();
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

  // =========================
  // UI
  // =========================
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