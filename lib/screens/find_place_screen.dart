import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindPlaceScreen extends StatefulWidget {
  const FindPlaceScreen({super.key});

  @override
  State<FindPlaceScreen> createState() => _FindPlaceScreenState();
}

class _FindPlaceScreenState extends State<FindPlaceScreen> {
  // Strathmore University coordinates
  static const LatLng _center = LatLng(-1.3094, 36.8148);

  // Example building markers (replace with real coordinates as needed)
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('library'),
      position: LatLng(-1.3090, 36.8152),
      infoWindow: InfoWindow(title: 'Strathmore Library'),
    ),
    const Marker(
      markerId: MarkerId('student_center'),
      position: LatLng(-1.3096, 36.8145),
      infoWindow: InfoWindow(title: 'Student Center'),
    ),
    const Marker(
      markerId: MarkerId('business_school'),
      position: LatLng(-1.3088, 36.8150),
      infoWindow: InfoWindow(title: 'Business School'),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Place')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: _center, zoom: 17),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
