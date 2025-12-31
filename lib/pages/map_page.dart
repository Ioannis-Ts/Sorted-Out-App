import 'package:flutter/material.dart';
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
  
  // Παίρνουμε το ID του τρέχοντος χρήστη
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadBins();
  }

  void _loadBins() {
    FirebaseFirestore.instance.collection('bins').snapshots().listen((snapshot) {
      final Set<Marker> newMarkers = snapshot.docs.map((doc) {
        final data = doc.data();
        final isRecycle = data['type'] == 'recycle';
        final name = data['name'] ?? 'Κάδος';

        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['lat'], data['lng']),
          onTap: () {
            _showBinOptions(doc.id, name, data['type']);
          },
          // ΕΠΙΣΤΡΟΦΗ ΣΤΑ ΧΡΩΜΑΤΑ (ΓΙΑ ΣΙΓΟΥΡΙΑ)
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isRecycle ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueOrange,
          ),
        );
      }).toSet();

      if (mounted) {
        setState(() {
          _markers = newMarkers;
        });
      }
    });
  }

  void _showAddBinDialog(LatLng position) {
    String type = 'recycle';
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Προσθήκη Κάδου'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Όνομα',
                hintText: 'π.χ. Κάδος Πλατείας',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => type = 'recycle',
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Ανακύκλωση', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => type = 'trash',
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Σκουπίδια', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ακύρωση')),
          TextButton(
            onPressed: () {
              _saveBinToFirebase(position, type, nameController.text);
              Navigator.pop(context);
            },
            child: const Text('Προσθήκη'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBinToFirebase(LatLng pos, String type, String name) async {
    await FirebaseFirestore.instance.collection('bins').add({
      'lat': pos.latitude,
      'lng': pos.longitude,
      'type': type,
      'name': name.isEmpty ? 'Νέος Κάδος' : name,
      'added_at': FieldValue.serverTimestamp(),
    });

    if (currentUserId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Profiles')
          .doc(currentUserId)
          .update({
        'totalpoints': FieldValue.increment(10),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ο κάδος προστέθηκε! Κέρδισες 10 πόντους! 🎉')),
        );
      }
    }
  }

  void _showBinOptions(String docId, String name, String type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Icon(type == 'recycle' ? Icons.recycling : Icons.delete, 
                        size: 30, color: type == 'recycle' ? Colors.blue : Colors.orange),
                  
                  const SizedBox(width: 10),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                type == 'recycle' ? 'Κάδος Ανακύκλωσης' : 'Κάδος Σκουπιδιών',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(docId);
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Διαγραφή Κάδου', style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(String markerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Διαγραφή Σημείου'),
        content: const Text('Είστε σίγουροι ότι θέλετε να διαγράψετε αυτόν τον κάδο;'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Όχι')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('bins').doc(markerId).delete();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ο κάδος διαγράφηκε!'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Ναι, διαγραφή', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            padding: const EdgeInsets.only(bottom: 80), 
            onLongPress: (LatLng pos) => _showAddBinDialog(pos),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            // Περνάμε το currentUserId στο Navbar!
            child: MainNavBar(currentIndex: 2, currentUserId: currentUserId), 
          ),
        ],
      ),
    );
  }
}