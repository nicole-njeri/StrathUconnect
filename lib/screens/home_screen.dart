import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'find_place_screen.dart';
import 'ask_question_screen.dart';
import 'checklist_screen.dart';
import 'campus_updates_screen.dart';
import 'events_calendar_screen.dart';
import 'resources_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> cards = [
    {
      'icon': Icons.place,
      'title': 'Find a Place',
      'screen': const FindPlaceScreen(),
    },
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
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        try {
                          await _authService.signOut();
                          if (mounted) {
                            Navigator.of(
                              context,
                            ).pop(); // Remove loading dialog
                            // Fallback: pop all and go to login
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.of(
                              context,
                            ).pop(); // Remove loading dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logout failed: ${e.toString()}'),
                              ),
                            );
                          }
                        }
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
            child: FutureBuilder<DocumentSnapshot>(
              future: _authService.getUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading user data."));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Could not find user data."));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                final userName = userData?['fullName']?.split(' ')[0] ?? 'User';

                return SingleChildScrollView(
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
                          'Hi $userName 👋',
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
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: StreamBuilder<int>(
        stream: _authService.currentUser != null
            ? _notificationService.getUnreadCount(_authService.currentUser!.uid)
            : Stream.value(0),
        builder: (context, snapshot) {
          final unreadCount = snapshot.data ?? 0;

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Handle navigation for different tabs
              if (index == 1) {
                // Resources tab
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResourcesScreen(),
                  ),
                );
                // Reset to home tab after navigation
                setState(() {
                  _currentIndex = 0;
                });
              } else if (index == 2) {
                // Notifications tab
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
                // Reset to home tab after navigation
                setState(() {
                  _currentIndex = 0;
                });
              }
              // You can add navigation logic for other tabs here
            },
            selectedItemColor: const Color(0xFF0A2B6B),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: 'Resources',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_none),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Notifications',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 8,
          );
        },
      ),
    );
  }
}
