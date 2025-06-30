import 'package:flutter/material.dart';
import 'package:strathapp/screens/admin/user_management_screen.dart';
import 'package:strathapp/services/auth_service.dart';
import 'package:strathapp/screens/login_screen.dart';

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
  static const Color lightGrey = Color(0xFFF4F6FA);
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
            title: const Text('Forum Moderation'),
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
            title: const Text('Send Notifications'),
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
      const _DashboardScreen(),
      const UserManagementScreen(),
      const _PlaceholderScreen(title: 'Manage Locations'),
      const _PlaceholderScreen(title: 'Manage Events'),
      const _PlaceholderScreen(title: 'Forum Moderation'),
      const _PlaceholderScreen(title: 'Onboarding Checklists'),
      const _PlaceholderScreen(title: 'Send Notifications'),
      const _PlaceholderScreen(title: 'Reports'),
      const _PlaceholderScreen(title: 'Support & Feedback'),
    ];

    final List<String> titles = [
      'Admin Dashboard',
      'User Management',
      'Manage Locations',
      'Manage Events',
      'Forum Moderation',
      'Onboarding Checklists',
      'Send Notifications',
      'Reports',
      'Support & Feedback',
    ];

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: Text(titles[_selectedPageIndex]),
        backgroundColor: primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
                  // Fallback: pop all and go to login
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // Remove loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: ${e.toString()}')),
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
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) {
    // Example data, replace with your real data source
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
      // Add more items as needed
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: const [
              _SummaryCard(
                title: 'Total Students',
                value: '120',
                icon: Icons.people_outline,
                color: _AdminPanelScreenState.primaryBlue,
              ),
              _SummaryCard(
                title: 'Active Events',
                value: '45',
                icon: Icons.event_available,
                color: _AdminPanelScreenState.primaryRed,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _QuickActionButton(title: 'Ban User', onTap: () {}),
          const SizedBox(height: 12),
          _QuickActionButton(
            title: 'Post Announcement',
            onTap: () {},
            isPrimary: false,
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200, // Set a height for the list
            child: ListView.builder(
              itemCount: recentActivities.length,
              itemBuilder: (context, index) {
                final activity = recentActivities[index];
                return _RecentActivityItem(
                  icon: activity['icon'],
                  text: activity['text'],
                  time: activity['time'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Widgets for Dashboard ---
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isPrimary;

  const _QuickActionButton({
    required this.title,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: isPrimary
            ? Colors.white
            : _AdminPanelScreenState.darkText,
        backgroundColor: isPrimary ? const Color(0xFF3A4B6A) : Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _RecentActivityItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String time;

  const _RecentActivityItem({
    required this.icon,
    required this.text,
    required this.time,
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

// --- Placeholder for other admin pages ---
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
