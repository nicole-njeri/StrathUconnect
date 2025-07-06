import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/shared_navigation_bar.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentIndex = 1;

  final List<Map<String, dynamic>> _allResources = [
    // Academic Resources
    {
      'category': 'Academic Resources',
      'title': 'Library Portal',
      'description':
          'Access digital library resources, research papers, and academic databases',
      'icon': Icons.library_books,
      'url': 'https://library.strathmore.edu',
      'type': 'online',
    },
    {
      'category': 'Academic Resources',
      'title': 'Student Portal',
      'description':
          'Access your academic records, course materials, and registration',
      'icon': Icons.school,
      'url': 'https://student.strathmore.edu',
      'type': 'online',
    },
    {
      'category': 'Academic Resources',
      'title': 'Learning Management System',
      'description': 'Access course content, assignments, and grades',
      'icon': Icons.computer,
      'url': 'https://lms.strathmore.edu',
      'type': 'online',
    },
    {
      'category': 'Academic Resources',
      'title': 'Academic Calendar',
      'description': 'Important dates, holidays, and exam schedules',
      'icon': Icons.calendar_today,
      'url': 'https://calendar.strathmore.edu',
      'type': 'online',
    },
    // Campus Services
    {
      'category': 'Campus Services',
      'title': 'Health Services',
      'description':
          'Book appointments, access medical records, and health information',
      'icon': Icons.local_hospital,
      'url': 'https://health.strathmore.edu',
      'type': 'online',
    },
    {
      'category': 'Campus Services',
      'title': 'IT Support',
      'description':
          'Get technical support, report issues, and access IT resources',
      'icon': Icons.support_agent,
      'url': 'https://it.strathmore.edu',
      'type': 'online',
    },
    {
      'category': 'Campus Services',
      'title': 'Campus Security',
      'description':
          'Emergency contacts, safety information, and incident reporting',
      'icon': Icons.security,
      'url': 'https://security.strathmore.edu',
      'type': 'online',
    },
    // Student Life
    {
      'category': 'Student Life',
      'title': 'Student Organizations',
      'description': 'Join clubs, societies, and student groups',
      'icon': Icons.groups,
      'url': 'https://clubs.strathmore.edu',
      'type': 'online',
    },
    {
      'category': 'Student Life',
      'title': 'Career Services',
      'description':
          'Career counseling, job opportunities, and internship programs',
      'icon': Icons.work,
      'url': 'https://careers.strathmore.edu',
      'type': 'online',
    },
    {
      'category': 'Student Life',
      'title': 'Campus Events',
      'description': 'View upcoming events, workshops, and activities',
      'icon': Icons.event,
      'url': 'https://events.strathmore.edu',
      'type': 'online',
    },
    // Quick Links
    {
      'category': 'Quick Links',
      'title': 'Campus Map',
      'description': 'Interactive campus map and building locations',
      'icon': Icons.map,
      'url': 'https://map.strathmore.edu',
      'type': 'online',
    },
    {
      'category': 'Quick Links',
      'title': 'Contact Directory',
      'description': 'Faculty, staff, and department contact information',
      'icon': Icons.contacts,
      'url': 'https://contacts.strathmore.edu',
      'type': 'online',
    },
    // Emergency Contacts (Offline)
    {
      'category': 'Emergency Contacts',
      'title': 'Campus Security',
      'description':
          'Emergency: +254-700-000-000 | Non-emergency: +254-700-000-001',
      'icon': Icons.emergency,
      'phone': '+254700000000',
      'type': 'phone',
    },
    {
      'category': 'Emergency Contacts',
      'title': 'Health Services',
      'description':
          'Medical emergencies: +254-700-000-002 | Appointments: +254-700-000-003',
      'icon': Icons.medical_services,
      'phone': '+254700000002',
      'type': 'phone',
    },
    {
      'category': 'Emergency Contacts',
      'title': 'IT Support Hotline',
      'description':
          'Technical support: +254-700-000-004 | Email: support@strathmore.edu',
      'icon': Icons.phone_in_talk,
      'phone': '+254700000004',
      'type': 'phone',
    },
  ];

  List<Map<String, dynamic>> get _filteredResources {
    if (_searchQuery.isEmpty) {
      return _allResources;
    }
    return _allResources.where((resource) {
      return resource['title'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          resource['description'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          resource['category'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  List<String> get _categories {
    return _filteredResources
        .map((resource) => resource['category'] as String)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EEDD),
      appBar: AppBar(
        title: const Text(
          'Resources',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A2B6B),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0A2B6B),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search resources...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Resources List
          Expanded(
            child: _filteredResources.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No resources found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final categoryResources = _filteredResources
                          .where((resource) => resource['category'] == category)
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2B6B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...categoryResources.map(
                            (resource) => _buildResourceCard(resource),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
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

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (resource['type'] == 'online') {
            launchUrl(Uri.parse(resource['url']));
          } else if (resource['type'] == 'phone') {
            launchUrl(Uri.parse('tel:${resource['phone']}'));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  resource['icon'],
                  color: const Color(0xFF0A2B6B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF0A2B6B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource['description'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                resource['type'] == 'phone'
                    ? Icons.phone
                    : Icons.arrow_forward_ios,
                size: 16,
                color: const Color(0xFF0A2B6B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
