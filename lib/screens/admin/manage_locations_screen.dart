import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ManageLocationsScreen extends StatefulWidget {
  const ManageLocationsScreen({super.key});

  @override
  State<ManageLocationsScreen> createState() => _ManageLocationsScreenState();
}

class _ManageLocationsScreenState extends State<ManageLocationsScreen> {
  String? _previewLocationId;
  LatLng? _previewLatLng;

  void _showPreviewOnMap(Map<String, dynamic> location) {
    if (location['coordinates'] is GeoPoint) {
      final geo = location['coordinates'] as GeoPoint;
      setState(() {
        _previewLocationId = location['locationName'];
        _previewLatLng = LatLng(geo.latitude, geo.longitude);
      });
    }
  }

  void _showAddEditLocationForm({DocumentSnapshot? doc}) {
    final isEdit = doc != null;
    final data = doc?.data() as Map<String, dynamic>? ?? {};
    final nameController = TextEditingController(
      text: data['locationName'] ?? '',
    );
    final typeController = TextEditingController(text: data['type'] ?? '');
    final descController = TextEditingController(
      text: data['description'] ?? '',
    );
    final imagesController = TextEditingController(
      text: (data['imageURLs'] as List?)?.join(', ') ?? '',
    );
    final directionsController = TextEditingController(
      text: data['directions'] ?? '',
    );
    final accessibilityController = TextEditingController(
      text: data['accessibilityNotes'] ?? '',
    );
    String? selectedCategory = data['category'];
    bool isVisible = data['isVisible'] != false;
    XFile? pickedImage;
    bool uploadingImage = false;
    
    // Initialize coordinates
    LatLng? selectedLocation;
    if (data['coordinates'] is GeoPoint) {
      final geo = data['coordinates'] as GeoPoint;
      selectedLocation = LatLng(geo.latitude, geo.longitude);
    } else {
      // Default to Strathmore University center
      selectedLocation = const LatLng(-1.3094, 36.8148);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Location' : 'Add Location',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Location Name'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: [
                      'Academic',
                      'Dining',
                      'Sports',
                      'Administration',
                      'Library',
                      'Residence',
                      'Other',
                    ].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) => setState(() => selectedCategory = val),
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: 'Type (e.g., building, lab)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Interactive Map Picker
                  const Text(
                    'Select Location on Map:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Click on the map to place the location marker',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  
                  // Quick Location Selection
                  const Text(
                    'Or select from common campus locations:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildQuickLocationChip('Main Library', const LatLng(-1.3090, 36.8152), setState, selectedLocation),
                      _buildQuickLocationChip('Student Center', const LatLng(-1.31012, 36.81308), setState, selectedLocation),
                      _buildQuickLocationChip('Auditorium', const LatLng(-1.31017, 36.81385), setState, selectedLocation),
                      _buildQuickLocationChip('Business School', const LatLng(-1.3088, 36.8150), setState, selectedLocation),
                      _buildQuickLocationChip('CS Building', const LatLng(-1.3096, 36.8145), setState, selectedLocation),
                      _buildQuickLocationChip('Main Entrance', const LatLng(-1.3094, 36.8148), setState, selectedLocation),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FlutterMap(
                        options: MapOptions(
                          center: selectedLocation,
                          zoom: 17.0,
                          onTap: (tapPosition, point) {
                            setState(() {
                              selectedLocation = point;
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          if (selectedLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 40.0,
                                  height: 40.0,
                                  point: selectedLocation!,
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
                  const SizedBox(height: 10),
                  
                  // Display selected coordinates
                  if (selectedLocation != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Coordinates: ${selectedLocation!.latitude.toStringAsFixed(6)}, ${selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 10),
                  
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: directionsController,
                    decoration: const InputDecoration(
                      labelText: 'Textual Directions',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: accessibilityController,
                    decoration: const InputDecoration(
                      labelText: 'Accessibility Notes (optional)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Switch(
                        value: isVisible,
                        onChanged: (val) => setState(() => isVisible = val),
                      ),
                      const Text('Visible to students'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: uploadingImage
                            ? null
                            : () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 75,
                                );
                                if (picked != null) {
                                  setState(() => uploadingImage = true);
                                  final ref = FirebaseStorage.instance.ref().child(
                                    'location_images/${DateTime.now().millisecondsSinceEpoch}_${picked.name}',
                                  );
                                  await ref.putData(await picked.readAsBytes());
                                  final url = await ref.getDownloadURL();
                                  imagesController.text =
                                      (imagesController.text.isEmpty
                                          ? ''
                                          : '${imagesController.text}, ') +
                                      url;
                                  setState(() {
                                    pickedImage = picked;
                                    uploadingImage = false;
                                  });
                                }
                              },
                        icon: const Icon(Icons.image),
                        label: Text(
                          uploadingImage ? 'Uploading...' : 'Add Image',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: imagesController,
                    decoration: const InputDecoration(
                      labelText: 'Image URLs (comma separated)',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final type = typeController.text.trim();
                      final desc = descController.text.trim();
                      final images = imagesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      final directions = directionsController.text.trim();
                      final accessibility = accessibilityController.text.trim();
                      
                      if (name.isEmpty ||
                          type.isEmpty ||
                          selectedLocation == null ||
                          selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all required fields and select a location on the map.'),
                          ),
                        );
                        return;
                      }
                      
                      final data = {
                        'locationName': name,
                        'type': type,
                        'category': selectedCategory,
                        'coordinates': GeoPoint(selectedLocation!.latitude, selectedLocation!.longitude),
                        'description': desc,
                        'imageURLs': images,
                        'directions': directions,
                        'accessibilityNotes': accessibility,
                        'isVisible': isVisible,
                      };
                      
                      try {
                        if (isEdit) {
                          await doc.reference.update(data);
                        } else {
                          await FirebaseFirestore.instance
                              .collection('campusLocations')
                              .add(data);
                        }
                        if (mounted) Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e')),
                        );
                      }
                    },
                    child: Text(isEdit ? 'Update Location' : 'Add Location'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickLocationChip(String label, LatLng coordinates, StateSetter setState, LatLng? selectedLocation) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          selectedLocation = coordinates;
        });
      },
      backgroundColor: selectedLocation == coordinates ? Colors.blue : Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selectedLocation == coordinates ? Colors.blue : Colors.transparent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EEDD),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditLocationForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Location'),
        backgroundColor: const Color(0xFF003399),
      ),
      body: Row(
        children: [
          // Locations List
          Expanded(
            flex: 2,
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
                final locations = snapshot.data!.docs;
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: locations.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = locations[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        title: Text(
                          data['locationName'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${data['type'] ?? ''}\n${data['description'] ?? ''}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              _showAddEditLocationForm(doc: doc);
                            } else if (value == 'delete') {
                              await doc.reference.delete();
                            } else if (value == 'preview') {
                              _showPreviewOnMap(data);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                            const PopupMenuItem(
                              value: 'preview',
                              child: Text('Preview on Map'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Map Preview
          if (_previewLatLng != null)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      options: MapOptions(center: _previewLatLng, zoom: 17.0),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: _previewLatLng!,
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
      ),
    );
  }
}
