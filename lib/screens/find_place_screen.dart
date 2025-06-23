import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FindPlaceScreen extends StatefulWidget {
  const FindPlaceScreen({super.key});

  @override
  State<FindPlaceScreen> createState() => _FindPlaceScreenState();
}

class _FindPlaceScreenState extends State<FindPlaceScreen> {
  // Strathmore University coordinates
  static const LatLng _center = LatLng(-1.3094, 36.8148);

  // Example building markers (replace with real coordinates as needed)
  final List<Marker> _markers = [
    Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(-1.3090, 36.8152),
      child: Icon(Icons.location_on, color: Colors.red, size: 40),
    ),
    Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(-1.3096, 36.8145),
      child: Icon(Icons.location_on, color: Colors.blue, size: 40),
    ),
    Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(-1.3088, 36.8150),
      child: Icon(Icons.location_on, color: Colors.green, size: 40),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Place')),
      body: FlutterMap(
        options: MapOptions(center: _center, zoom: 17.0),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
