import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Η αρχική θέση της κάμερας (Αθήνα)
  static const CameraPosition _athens = CameraPosition(
    target: LatLng(37.9838, 23.7275),
    zoom: 14.0, // Όσο μεγαλύτερο, τόσο πιο κοντινό το ζουμ
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle Points'),
        backgroundColor: Colors.green[400],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _athens,
        onMapCreated: (GoogleMapController controller) {
          // Εδώ θα μπορούμε να ελέγξουμε τον χάρτη μελλοντικά
        },
        // Εδώ θα βάλουμε αργότερα τους κάδους (Markers)
        markers: {}, 
      ),
    );
  }
}