import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBins();
  }

void _loadBins() {
    FirebaseFirestore.instance.collection('bins').snapshots().listen((snapshot) {
      final Set<Marker> newMarkers = snapshot.docs.map((doc) {
        final data = doc.data();
        print("Type from Firebase: '${data['type']}'");
        
        // Ελέγχουμε τον τύπο του κάδου
        final isRecycle = data['type'] == 'recycle';
        final name = data['name'] ?? 'Κάδος';

        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['lat'], data['lng']),
          onTap: () {
            _showBinOptions(doc.id, name, data['type']);
          },
          // --- ΕΔΩ ΕΙΝΑΙ Η ΑΛΛΑΓΗ ΤΩΝ ΧΡΩΜΑΤΩΝ ---
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isRecycle 
                ? BitmapDescriptor.hueBlue  // ΑΝ ΕΙΝΑΙ ΑΝΑΚΥΚΛΩΣΗ -> ΜΠΛΕ
                : BitmapDescriptor.hueOrange // ΑΛΛΙΩΣ -> ΠΟΡΤΟΚΑΛΙ
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

  // --- ΛΕΙΤΟΥΡΓΙΑ ΠΡΟΣΘΗΚΗΣ (Long Press) ---
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Ανακύκλωση', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => type = 'trash',
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
    // ... (αφού αποθηκευτεί ο κάδος) ...

  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // --- ΑΛΛΑΓΗ ΕΔΩ ---
    await FirebaseFirestore.instance
        .collection('Profiles') // Ψάχνουμε στο Profiles
        .doc(user.uid)
        .update({
      // Αυξάνουμε το 'totalpoints' αντί για το 'points'
      'totalpoints': FieldValue.increment(10), 
    });

    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ο κάδος προστέθηκε! Κέρδισες 10 πόντους! 🎉')),
      );
    }
  }
}

  // --- ΝΕΑ ΛΕΙΤΟΥΡΓΙΑ: BOTTOM SHEET ΓΙΑ ΔΙΑΓΡΑΦΗ ---
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
              // Τίτλος και Εικονίδιο
              Row(
                children: [
                  Icon(
                    type == 'recycle' ? Icons.recycling : Icons.delete_outline,
                    color: type == 'recycle' ? Colors.green : Colors.red,
                    size: 30,
                  ),
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
              // Κουμπί Διαγραφής
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Κλείσε το μενού
                    _confirmDelete(docId); // Ξεκίνα τη διαγραφή
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Διαγραφή Κάδου', style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- ΕΠΙΒΕΒΑΙΩΣΗ ΔΙΑΓΡΑΦΗΣ ---
  void _confirmDelete(String markerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Διαγραφή Σημείου'),
        content: const Text('Είστε σίγουροι ότι θέλετε να διαγράψετε αυτόν τον κάδο;'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Όχι'),
          ),
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
      appBar: AppBar(
        title: const Text('Recycle Points', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[600],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        markers: _markers,
        myLocationEnabled: true,
        onLongPress: (LatLng pos) => _showAddBinDialog(pos),
      ),
    );
  }
}