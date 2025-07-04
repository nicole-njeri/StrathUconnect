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
        backgroundColor: const Color(0xFF0A2B6B),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6EEDD),
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
                color: Color(0xFF0A2B6B),
              ),
            ),
            const SizedBox(height: 20),
            ...eventSections.map(
              (section) => _buildSection(section['title'], section['events']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF0A2B6B),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...events.map<Widget>(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.event, color: Color(0xFF0A2B6B)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Color(0xFF0A2B6B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${event['date']} · ${event['location']}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
