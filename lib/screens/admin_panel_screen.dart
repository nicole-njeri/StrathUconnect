import 'package:flutter/material.dart';
import 'package:strathapp/screens/admin/user_management_screen.dart';
import 'package:strathapp/screens/admin/create_event_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strathapp/services/auth_service.dart';
import 'package:strathapp/screens/login_screen.dart';
import 'package:strathapp/screens/admin/manage_locations_screen.dart';
import 'package:strathapp/screens/admin/forum_moderation_screen.dart';
import 'package:strathapp/screens/admin/checklist_management_screen.dart';
import 'package:strathapp/screens/admin/notification_management_screen.dart';
import 'package:strathapp/screens/admin/reports_screen.dart';
import 'package:strathapp/screens/admin/support_feedback_screen.dart';
import 'package:strathapp/widgets/strathmore_logo.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final AuthService _authService = AuthService();
  int _selectedPageIndex = 0;

  // Define your color palette
  static const Color primaryBlue = Color(0xFF003399);
  static const Color primaryRed = Color(0xFFE1251B);
  static const Color darkText = Color(0xFF333333);

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: primaryBlue),
            child: Text(
              'Admin Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => _selectPage(0),
            selected: _selectedPageIndex == 0,
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('User Management'),
            onTap: () => _selectPage(1),
            selected: _selectedPageIndex == 1,
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Manage Locations'),
            onTap: () => _selectPage(2),
            selected: _selectedPageIndex == 2,
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Manage Events'),
            onTap: () => _selectPage(3),
            selected: _selectedPageIndex == 3,
          ),
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text('Manage Forum'),
            onTap: () => _selectPage(4),
            selected: _selectedPageIndex == 4,
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Onboarding Checklists'),
            onTap: () => _selectPage(5),
            selected: _selectedPageIndex == 5,
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Manage Notifications'),
            onTap: () => _selectPage(6),
            selected: _selectedPageIndex == 6,
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () => _selectPage(7),
            selected: _selectedPageIndex == 7,
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Support & Feedback'),
            onTap: () => _selectPage(8),
            selected: _selectedPageIndex == 8,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _DashboardScreen(adminNameFuture: _authService.getUserFullName()),
      const UserManagementScreen(),
      const ManageLocationsScreen(),
      const ManageEventsScreen(),
      const ForumModerationScreen(),
      const ChecklistManagementScreen(),
      const NotificationManagementScreen(),
      const ReportsScreen(),
      const SupportFeedbackScreen(),
    ];

    final List<String> titles = [
      'Admin Dashboard',
      'User Management',
      'Manage Locations',
      'Manage Events',
      'Manage Forum',
      'Onboarding Checklists',
      'Manage Notifications',
      'Reports',
      'Support & Feedback',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Strathmore Logo between nav icon and title
            const SizedBox(
              height: 36,
              child: Padding(
                padding: EdgeInsets.only(right: 12),
                child: StrathmoreLogo(size: 32),
              ),
            ),
            Text(
              titles[_selectedPageIndex],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
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
                  Navigator.of(context).pop(); // Remove loading dialog
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // Remove loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: \\${e.toString()}')),
                  );
                }
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: pages[_selectedPageIndex],
    );
  }
}

// --- Dashboard Screen ---
class _DashboardScreen extends StatelessWidget {
  final Future<String?> adminNameFuture;
  const _DashboardScreen({required this.adminNameFuture});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recentActivities = [
      {
        'icon': Icons.flag,
        'text': 'John Doe reported a post',
        'time': '2 hours ago',
      },
      {
        'icon': Icons.person_add,
        'text': 'New user registered: Jane Smith',
        'time': '4 hours ago',
      },
      {
        'icon': Icons.add_circle,
        'text': 'Event "Study Group" created',
        'time': '6 hours ago',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient background (no logo, no welcome message)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _AdminPanelScreenState.primaryBlue,
                      Color(0xFF3A4B6A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: FutureBuilder<String?>(
                  future: adminNameFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(height: 32);
                    }
                    final adminName = snapshot.data ?? 'Admin';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $adminName!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Here is your dashboard overview.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Summary Cards
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Students',
                        value: '120',
                        icon: Icons.people_outline,
                        color: _AdminPanelScreenState.primaryBlue,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: SummaryCard(
                        title: 'Active Events',
                        value: '45',
                        icon: Icons.event_available,
                        color: _AdminPanelScreenState.primaryRed,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _AdminPanelScreenState.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.block, color: Colors.white),
                        label: const Text('Ban User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _AdminPanelScreenState.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.announcement,
                          color: _AdminPanelScreenState.primaryBlue,
                        ),
                        label: const Text('Announcement'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _AdminPanelScreenState.primaryBlue,
                          side: const BorderSide(
                            color: _AdminPanelScreenState.primaryBlue,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Recent Activity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _AdminPanelScreenState.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: recentActivities.length,
                    separatorBuilder: (context, i) => const Divider(),
                    itemBuilder: (context, index) {
                      final activity = recentActivities[index];
                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _AdminPanelScreenState.primaryBlue
                                .withOpacity(0.1),
                            child: Icon(
                              activity['icon'],
                              color: _AdminPanelScreenState.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity['text'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  activity['time'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

// --- Helper Widgets for Dashboard ---
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Color textColor;

  const SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(title, style: TextStyle(color: textColor.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}

class RecentActivityItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String time;

  const RecentActivityItem({
    required this.icon,
    required this.text,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: _AdminPanelScreenState.darkText),
        title: Text(text),
        subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}

// --- Manage Events Screen ---
class ManageEventsScreen extends StatelessWidget {
  const ManageEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EEDD),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateEventScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
        backgroundColor: _AdminPanelScreenState.primaryBlue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: const BoxDecoration(
              color: _AdminPanelScreenState.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: const Text(
              'Manage Events',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('campusEvents')
                  .orderBy('eventDate', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No events found.'));
                }
                final events = snapshot.data!.docs;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: events.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final event = events[index].data() as Map<String, dynamic>;
                    final eventName = event['eventName'] ?? 'Untitled';
                    final description = event['description'] ?? '';
                    final eventDate = (event['eventDate'] as Timestamp?)
                        ?.toDate();
                    final eventTime = event['eventTime'] ?? '';
                    final locationID = event['locationID'] ?? '';
                    final organizer = event['organizer'] ?? '';
                    return Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.95),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eventName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(description),
                              const SizedBox(height: 8),
                              Text(
                                'Date: \\${eventDate != null ? eventDate.toLocal().toString().split(' ')[0] : 'N/A'}',
                              ),
                              Text('Time: \\$eventTime'),
                              Text('Location: \\$locationID'),
                              Text('Organizer: \\$organizer'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
