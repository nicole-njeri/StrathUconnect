import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class ManageLocationsScreen extends StatefulWidget {
  const ManageLocationsScreen({super.key});

  @override
  State<ManageLocationsScreen> createState() => _ManageLocationsScreenState();
}

class _ManageLocationsScreenState extends State<ManageLocationsScreen> {
  static const LatLng _center = LatLng(-1.3094, 36.8148);
  String _searchQuery = '';
  Map<String, dynamic>? _selectedLocation;
  LatLng? _selectedLatLng;

  // Route drawing state (optional for admin, but kept for UI parity)
  Map<String, dynamic>? _startLocation;
  Map<String, dynamic>? _endLocation;
  LatLng? _startLatLng;
  LatLng? _endLatLng;
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  String? _routeError;

  void _selectLocation(Map<String, dynamic> data, LatLng latLng) {
    setState(() {
      _selectedLocation = data;
      _selectedLatLng = latLng;
    });
  }

  void _showAddEditDialog({Map<String, dynamic>? location, String? docId}) {
    final nameController = TextEditingController(
      text: location?['locationName'] ?? '',
    );
    final typeController = TextEditingController(text: location?['type'] ?? '');
    final descController = TextEditingController(
      text: location?['description'] ?? '',
    );
    final latController = TextEditingController(
      text: location?['coordinates']?.latitude?.toString() ?? '',
    );
    final lngController = TextEditingController(
      text: location?['coordinates']?.longitude?.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location == null ? 'Add Location' : 'Edit Location'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final type = typeController.text.trim();
              final desc = descController.text.trim();
              final lat = double.tryParse(latController.text.trim());
              final lng = double.tryParse(lngController.text.trim());
              if (name.isEmpty || type.isEmpty || lat == null || lng == null)
                return;
              final data = {
                'locationName': name,
                'type': type,
                'description': desc,
                'coordinates': GeoPoint(lat, lng),
              };
              if (docId == null) {
                await FirebaseFirestore.instance
                    .collection('campusLocations')
                    .add(data);
              } else {
                await FirebaseFirestore.instance
                    .collection('campusLocations')
                    .doc(docId)
                    .update(data);
              }
              if (mounted) Navigator.pop(context);
            },
            child: Text(location == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _deleteLocation(String docId) async {
    await FirebaseFirestore.instance
        .collection('campusLocations')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Locations')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Add Location',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or type...',
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('campusLocations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No locations found.'));
                }
                final locations = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['locationName'] ?? '')
                      .toString()
                      .toLowerCase();
                  final type = (data['type'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) ||
                      type.contains(_searchQuery);
                }).toList();
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: locations.length,
                        separatorBuilder: (context, i) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final doc = locations[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final geo = data['coordinates'] as GeoPoint?;
                          final latLng = geo != null
                              ? LatLng(geo.latitude, geo.longitude)
                              : null;
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                data['locationName'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${data['type'] ?? ''}\n${data['description'] ?? ''}',
                              ),
                              isThreeLine: true,
                              onTap: latLng != null
                                  ? () => _selectLocation(data, latLng)
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _showAddEditDialog(
                                      location: data,
                                      docId: doc.id,
                                    ),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteLocation(doc.id),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: FlutterMap(
                              options: MapOptions(
                                center: _selectedLatLng ?? _center,
                                zoom: 17.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                ),
                                if (_selectedLatLng != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        width: 80.0,
                                        height: 80.0,
                                        point: _selectedLatLng!,
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedLocation!['locationName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selectedLocation!['type'] ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(_selectedLocation!['description'] ?? ''),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
