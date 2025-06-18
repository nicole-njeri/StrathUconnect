import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'find_place_screen.dart';
import 'ask_question_screen.dart';
import 'checklist_screen.dart';
import 'campus_updates_screen.dart';
import 'events_calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  DocumentSnapshot? _userSnapshot;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;

  final List<Map<String, dynamic>> cards = [
    {'icon': Icons.place, 'title': 'Find a Place', 'screen': const FindPlaceScreen()},
    {
      'icon': Icons.chat_bubble_outline,
      'title': 'Ask a Question',
      'screen': const AskQuestionScreen(),
    },
    {
      'icon': Icons.check_box,
      'title': 'My Checklist',
      'screen': const ChecklistScreen(),
    },
    {
      'icon': Icons.campaign_outlined,
      'title': 'Campus Updates',
      'screen': const CampusUpdatesScreen(),
    },
    {
      'icon': Icons.event,
      'title': 'Events Calendar',
      'screen': const EventsCalendarScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final snapshot = await _authService.getUserDetails();
      if (mounted) {
        setState(() {
          _userSnapshot = snapshot;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load user data.";
          _isLoading = false;
        });
      }
    }
  }

  String get _userName {
    if (_userSnapshot != null && _userSnapshot!.exists) {
      final data = _userSnapshot!.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('fullName')) {
        return data['fullName'].split(' ')[0]; // Just get first name
      }
    }
    return 'User'; // Default name
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          // Blue header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0A2B6B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 48,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'StrathUConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Logout',
                      onPressed: () async {
                        await _authService.signOut();
                        // The StreamBuilder in main.dart will handle navigation
                      },
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Hi $_userName 👋',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A2B6B),
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...cards.map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(
                              card['icon'],
                              color: const Color(0xFF0A2B6B),
                              size: 32,
                            ),
                            title: Text(
                              card['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => card['screen'],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // You can add navigation logic for other tabs here
        },
        selectedItemColor: const Color(0xFF0A2B6B),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}
