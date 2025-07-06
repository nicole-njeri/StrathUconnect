import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/shared_navigation_bar.dart';

class FindPlaceScreen extends StatefulWidget {
  const FindPlaceScreen({super.key});

  @override
  State<FindPlaceScreen> createState() => _FindPlaceScreenState();
}

class _FindPlaceScreenState extends State<FindPlaceScreen> {
  // Strathmore University coordinates
  static const LatLng _center = LatLng(-1.3094, 36.8148);

  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  int _currentIndex = 0;

  LatLng? _userLocation;
  LatLng? _destination;
  List<LatLng> _routePath = [];
  bool _isSearching = false;
  bool _showRoute = false;
  String _selectedPlace = '';

  // Campus locations with real coordinates
  final List<Map<String, dynamic>> _campusLocations = [
    {
      'name': "Strathmore Students' Centre",
      'description': 'Student activities, dining, and recreation',
      'coordinates': const LatLng(-1.31012, 36.81308),
      'icon': Icons.sports_esports,
      'color': Colors.red,
    },
    {
      'name': 'Strathmore University Auditorium',
      'description': 'Main auditorium for events and ceremonies',
      'coordinates': const LatLng(-1.31017, 36.81385),
      'icon': Icons.event,
      'color': Colors.purple,
    },
    {
      'name': 'Main Library',
      'description': 'University library and study spaces',
      'coordinates': const LatLng(-1.3090, 36.8152),
      'icon': Icons.library_books,
      'color': Colors.blue,
    },
    {
      'name': 'Computer Science Building',
      'description': 'CS department and computer labs',
      'coordinates': const LatLng(-1.3096, 36.8145),
      'icon': Icons.computer,
      'color': Colors.green,
    },
    {
      'name': 'Business School',
      'description': 'Business and economics programs',
      'coordinates': const LatLng(-1.3088, 36.8150),
      'icon': Icons.business,
      'color': Colors.orange,
    },
    {
      'name': 'Health Services',
      'description': 'Medical clinic and health center',
      'coordinates': const LatLng(-1.3092, 36.8140),
      'icon': Icons.local_hospital,
      'color': Colors.pink,
    },
    {
      'name': 'Sports Complex',
      'description': 'Gym, swimming pool, and sports facilities',
      'coordinates': const LatLng(-1.3105, 36.8142),
      'icon': Icons.sports_soccer,
      'color': Colors.indigo,
    },
    {
      'name': 'Parking Lot A',
      'description': 'Main student parking area',
      'coordinates': const LatLng(-1.3085, 36.8135),
      'icon': Icons.local_parking,
      'color': Colors.grey,
    },
  ];

  List<Map<String, dynamic>> get _filteredLocations {
    if (_searchController.text.isEmpty) {
      return _campusLocations;
    }
    return _campusLocations.where((location) {
      return location['name'].toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          location['description'].toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _simulateUserLocation();
  }

  void _simulateUserLocation() {
    // Simulate user location (in a real app, this would come from GPS)
    _userLocation = const LatLng(-1.3085, 36.8135); // Parking Lot A
  }

  void _selectDestination(Map<String, dynamic> location) {
    setState(() {
      _destination = location['coordinates'];
      _selectedPlace = location['name'];
      _showRoute = true;
      _isSearching = false;
    });
    _calculateRoute();
  }

  void _calculateRoute() {
    if (_userLocation != null && _destination != null) {
      // Simulate route calculation (in a real app, this would use a routing API)
      setState(() {
        _routePath = [
          _userLocation!,
          const LatLng(-1.3090, 36.8140), // Intermediate point
          const LatLng(-1.3095, 36.8135), // Intermediate point
          _destination!,
        ];
      });

      // Fit map to show the entire route
      _mapController.fitBounds(
        LatLngBounds.fromPoints([_userLocation!, _destination!]),
        options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
      );
    }
  }

  void _clearRoute() {
    setState(() {
      _routePath = [];
      _showRoute = false;
      _destination = null;
      _selectedPlace = '';
    });
  }

  void _getDirections() {
    if (_destination != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildDirectionsSheet(),
      );
    }
  }

  Widget _buildDirectionsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Directions to $_selectedPlace',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2B6B),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDirectionStep(
                  1,
                  'Start from Parking Lot A',
                  'Your current location',
                ),
                _buildDirectionStep(
                  2,
                  'Walk north towards the main campus',
                  'Follow the paved walkway',
                ),
                _buildDirectionStep(
                  3,
                  'Turn right at the fountain',
                  'Continue past the library',
                ),
                _buildDirectionStep(
                  4,
                  'Arrive at $_selectedPlace',
                  'Destination reached',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _startNavigation();
                        },
                        icon: const Icon(Icons.navigation),
                        label: const Text('Start Navigation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A2B6B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0A2B6B),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionStep(int step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF0A2B6B),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startNavigation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigation Started'),
        content: Text('Following route to $_selectedPlace'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Find a Place',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A2B6B),
        elevation: 0,
        actions: [
          if (_showRoute)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: _clearRoute,
              tooltip: 'Clear route',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0A2B6B),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for a place...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _isSearching = false;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                if (_isSearching && _filteredLocations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = _filteredLocations[index];
                        return ListTile(
                          leading: Icon(
                            location['icon'],
                            color: location['color'],
                          ),
                          title: Text(location['name']),
                          subtitle: Text(location['description']),
                          onTap: () => _selectDestination(location),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _center,
                zoom: 17.0,
                onTap: (_, __) {
                  if (_isSearching) {
                    setState(() {
                      _isSearching = false;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                // Route path
                if (_routePath.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePath,
                        strokeWidth: 4,
                        color: const Color(0xFF0A2B6B),
                      ),
                    ],
                  ),
                // Markers
                MarkerLayer(
                  markers: [
                    // User location marker
                    if (_userLocation != null)
                      Marker(
                        width: 40,
                        height: 40,
                        point: _userLocation!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    // Destination marker
                    if (_destination != null)
                      Marker(
                        width: 40,
                        height: 40,
                        point: _destination!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    // Campus location markers
                    ..._campusLocations.map(
                      (location) => Marker(
                        width: 30,
                        height: 30,
                        point: location['coordinates'],
                        child: Icon(
                          location['icon'],
                          color: location['color'],
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Navigation button
          if (_showRoute)
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _getDirections,
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2B6B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: SharedNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
