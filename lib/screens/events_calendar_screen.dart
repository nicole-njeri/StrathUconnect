import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
        title: const Text(
          'Events Calendar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF0A2B6B),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6EEDD),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('campusEvents')
            .orderBy('eventDate')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final events = snapshot.data?.docs ?? [];
          if (events.isEmpty) {
            return const Center(child: Text('No events found.'));
          }
          // Group events by week
          final now = DateTime.now();
          final thisWeek = <Map<String, dynamic>>[];
          final upcoming = <Map<String, dynamic>>[];
          final campusLife = <Map<String, dynamic>>[];
          for (final doc in events) {
            final data = doc.data() as Map<String, dynamic>;
            final eventDate = (data['eventDate'] as Timestamp?)?.toDate();
            if (eventDate == null) continue;
            final daysDiff = eventDate.difference(now).inDays;
            if (daysDiff >= 0 && daysDiff <= 7) {
              thisWeek.add(data);
            } else if (daysDiff > 7 && daysDiff <= 30) {
              upcoming.add(data);
            } else if (daysDiff > 30) {
              campusLife.add(data);
            }
          }
          return SingleChildScrollView(
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
                if (thisWeek.isNotEmpty)
                  _buildSection("This Week's Events", thisWeek),
                if (upcoming.isNotEmpty)
                  _buildSection('Upcoming Workshops', upcoming),
                if (campusLife.isNotEmpty)
                  _buildSection('Campus Life', campusLife),
              ],
            ),
          );
        },
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
                                event['eventName'] ?? event['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Color(0xFF0A2B6B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatEventDate(event['eventDate'])}  b7 ' +
                                    (event['locationID'] ??
                                        event['location'] ??
                                        ''),
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                              if (event['description'] != null &&
                                  (event['description'] as String).isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    event['description'],
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
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

  String _formatEventDate(dynamic eventDate) {
    if (eventDate is Timestamp) {
      return DateFormat('EEE, d MMM').format(eventDate.toDate());
    } else if (eventDate is DateTime) {
      return DateFormat('EEE, d MMM').format(eventDate);
    } else if (eventDate is String) {
      return eventDate;
    }
    return '';
  }
}
