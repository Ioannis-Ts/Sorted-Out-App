import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/main_nav_bar.dart';
import 'package:geolocator/geolocator.dart'; // Βεβαιώσου ότι έχεις αυτό το πακέτο

Future<void> _ensureLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    // Μπορείς να δείξεις ένα dialog εδώ
    return;
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // 1. Controller για να κουνάμε τον χάρτη
  GoogleMapController? _mapController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.9838, 23.7275), // Athens center default
    zoom: 14.0,
  );

  // --- STATE VARIABLES ---
  Set<Marker> _markers = {};
  List<DocumentSnapshot> _binDocsCache = [];
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
  bool _isInitLoadDone = false;

  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _subscribeToBins();
    _ensureLocationPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitLoadDone) {
      _isInitLoadDone = true;
      _updateIconsForZoom(_currentZoom);
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    _mapController?.dispose(); // Καθαρισμός controller
    super.dispose();
  }

  // --- 2. ΣΥΝΑΡΤΗΣΗ ΓΙΑ ΜΕΤΑΒΑΣΗ ΣΤΗΝ ΤΟΠΟΘΕΣΙΑ ---
  Future<void> _goToUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 17.0, // Κοντινό ζουμ
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  // ... (ΟΙ ΥΠΟΛΟΙΠΕΣ ΣΥΝΑΡΤΗΣΕΙΣ ΣΟΥ ΠΑΡΑΜΕΝΟΥΝ ΙΔΙΕΣ: _subscribeToBins, _updateIconsForZoom κλπ) ...
  // ΓΙΑ ΣΥΝΤΟΜΙΑ ΔΕΝ ΤΙΣ ΞΑΝΑΓΡΑΦΩ ΟΛΕΣ, ΕΙΝΑΙ ΙΔΙΕΣ ΜΕ ΤΟΝ ΚΩΔΙΚΑ ΣΟΥ
  // ΑΝΤΙΓΡΑΨΕ ΤΙΣ ΑΠΟ ΤΟΝ ΠΑΛΙΟ ΣΟΥ ΚΩΔΙΚΑ ΑΝ ΛΕΙΠΟΥΝ

  void _subscribeToBins() {
    _firestoreSubscription = FirebaseFirestore.instance
        .collection('bins')
        .snapshots()
        .listen((snapshot) {
      _binDocsCache = snapshot.docs;
      if (_iconsLoaded) {
        _renderMarkers();
      }
    });
  }

  Future<void> _updateIconsForZoom(double zoom) async {
    if (!mounted) return;
    final int generation = ++_iconGeneration;
    final double dpr = MediaQuery.of(context).devicePixelRatio;
    double logicalSize = (zoom * 2.2 / 22).clamp(10.0, 90.0);
    final int finalSize = (logicalSize * dpr).toInt();

    try {
      final blue = await _createMarkerIcon('blue', size: finalSize);
      final yellow = await _createMarkerIcon('yellow', size: finalSize);
      final grey = await _createMarkerIcon('grey', size: finalSize);
      final brown = await _createMarkerIcon('brown', size: finalSize);
      final green = await _createMarkerIcon('green', size: finalSize);

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
      final ByteData? resized =
          await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
      if (resized == null) return BitmapDescriptor.defaultMarker;
      return BitmapDescriptor.bytes(resized.buffer.asUint8List());
    } catch (e) {
      return BitmapDescriptor.defaultMarker;
    }
  }

  void _renderMarkers() {
    if (!_iconsLoaded) return;
    final Set<Marker> newMarkers = {};
    for (final doc in _binDocsCache) {
      final data = doc.data() as Map<String, dynamic>;
      final type = data['type'] as String? ?? 'recycle_general';
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

  void _onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  void _onCameraIdle() {
    if (_iconsLoaded) {
      _updateIconsForZoom(_currentZoom);
    }
  }
  
  // (DIALOGS: _showAddBinDialog, _saveBin, _showBinOptions - ΙΔΙΑ ΜΕ ΠΡΙΝ)
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    const Text('Επιλέξτε Τύπο:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        buildTypeBtn('recycle_general', 'Γενική', Colors.blue),
                        buildTypeBtn('recycle_paper', 'Χαρτί', Colors.orange),
                        buildTypeBtn(
                            'recycle_electronics', 'Ηλεκτρικές', Colors.grey[700]!),
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
                label: const Text('Διαγραφή Κάδου',
                    style: TextStyle(color: Colors.white)),
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
            // 3. Σύνδεση με τον Controller
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Το κλείνουμε για να βάλουμε το δικό μας
            zoomControlsEnabled: false,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            onLongPress: _showAddBinDialog,
            // Δεν χρειάζεται πλέον τόσο μεγάλο padding γιατί βάλαμε δικό μας κουμπί
            padding: const EdgeInsets.only(bottom: 0), 
          ),

          // 4. CUSTOM BUTTON TOΠΟΘΕΣΙΑΣ
          Positioned(
            right: 20, // Δεξιά μεριά
            bottom: 110, // Πάνω από το Nav Bar (που είναι περίπου 80-90)
            child: FloatingActionButton(
              heroTag: "my_location_btn",
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              elevation: 4,
              onPressed: _goToUserLocation, // Καλεί τη συνάρτηση που φτιάξαμε
              child: const Icon(Icons.my_location, size: 28),
            ),
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