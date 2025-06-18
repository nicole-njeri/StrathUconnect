import 'package:flutter/material.dart';

class EventsCalendarScreen extends StatefulWidget {
  const EventsCalendarScreen({super.key});

  @override
  State<EventsCalendarScreen> createState() => _EventsCalendarScreenState();
}

class _EventsCalendarScreenState extends State<EventsCalendarScreen> {
  // Example event data
  final List<Map<String, dynamic>> eventSections = [
    {
      'title': "This Week's Events",
      'events': [
        {
          'name': 'Freshers Welcome Party',
          'date': 'Mon, 10 June',
          'location': 'Student Center',
        },
        {
          'name': 'Library Orientation',
          'date': 'Wed, 12 June',
          'location': 'Main Library',
        },
      ],
    },
    {
      'title': 'Upcoming Workshops',
      'events': [
        {
          'name': 'Research Skills Workshop',
          'date': 'Fri, 14 June',
          'location': 'Room 204',
        },
        {
          'name': 'Career Guidance Talk',
          'date': 'Sat, 15 June',
          'location': 'Auditorium',
        },
      ],
    },
    {
      'title': 'Campus Life',
      'events': [
        {
          'name': 'Student Clubs Expo',
          'date': 'Sun, 16 June',
          'location': 'Sports Grounds',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF1A3C7C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming Events",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF1A3C7C),
              ),
            ),
            const SizedBox(height: 16),
            ...eventSections.map(
              (section) => _buildSection(section['title'], section['events']),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Events tab
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          // TODO: Implement navigation if needed
        },
      ),
    );
  }

  Widget _buildSection(String title, List events) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...events.map<Widget>(
              (event) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event, color: Color(0xFF1A3C7C)),
                title: Text(event['name']),
                subtitle: Text('${event['date']} • ${event['location']}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
