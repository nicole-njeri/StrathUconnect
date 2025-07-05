import 'package:flutter/material.dart';
import 'package:strathapp/screens/admin/user_management_screen.dart';
import 'package:strathapp/screens/admin/create_event_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strathapp/services/auth_service.dart';
import 'package:strathapp/screens/admin/manage_locations_screen.dart';
import 'package:strathapp/screens/admin/forum_moderation_screen.dart';
import 'package:strathapp/screens/admin/checklist_management_screen.dart';
import 'package:strathapp/screens/admin/notification_management_screen.dart';
import 'package:strathapp/screens/admin/reports_screen.dart';
import 'package:strathapp/screens/admin/support_feedback_screen.dart';
import 'package:strathapp/widgets/strathmore_logo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
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
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () async {
              final user = await FirebaseFirestore.instance
                  .collection('admins')
                  .doc(_authService.currentUser?.uid)
                  .get();
              final data = user.data() ?? {};
              final name = data['fullName'] ?? 'Admin';
              final email = data['email'] ?? '';
              final department = data['department'] ?? 'N/A';
              final profilePictureURL = data['profilePictureURL'];
              if (!context.mounted) return;
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) {
                  return _AdminProfileEditModal(
                    uid: _authService.currentUser?.uid,
                    initialName: name,
                    initialDepartment: department,
                    initialProfilePictureURL: profilePictureURL,
                    email: email,
                  );
                },
              );
              if (result != null && mounted) {
                setState(() {}); // Refresh profile info after update
              }
            },
          ),
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
                    final doc = events[index];
                    final event = doc.data() as Map<String, dynamic>;
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      eventName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    tooltip: 'Edit',
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) => _EditEventDialog(
                                          docId: doc.id,
                                          event: event,
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Delete',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Event'),
                                          content: const Text(
                                            'Are you sure you want to delete this event?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await FirebaseFirestore.instance
                                            .collection('campusEvents')
                                            .doc(doc.id)
                                            .delete();
                                      }
                                    },
                                  ),
                                ],
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

// --- Place the modal widget at the top-level, after the AdminPanelScreen and its state ---

class _AdminProfileEditModal extends StatefulWidget {
  final String? uid;
  final String initialName;
  final String initialDepartment;
  final String? initialProfilePictureURL;
  final String email;

  const _AdminProfileEditModal({
    required this.uid,
    required this.initialName,
    required this.initialDepartment,
    required this.initialProfilePictureURL,
    required this.email,
  });

  @override
  State<_AdminProfileEditModal> createState() => _AdminProfileEditModalState();
}

class _AdminProfileEditModalState extends State<_AdminProfileEditModal> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _department;
  String? _profilePictureURL;
  XFile? _pickedImage;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _department = widget.initialDepartment;
    _profilePictureURL = widget.initialProfilePictureURL;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  Future<String?> _uploadImage(String uid) async {
    if (_pickedImage == null) return _profilePictureURL;
    final ref = FirebaseStorage.instance.ref().child(
      'admin_profile_images/$uid.jpg',
    );
    await ref.putData(await _pickedImage!.readAsBytes());
    return await ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = widget.uid;
      if (uid == null) throw Exception('User not found');
      final url = await _uploadImage(uid);
      await FirebaseFirestore.instance.collection('admins').doc(uid).update({
        'fullName': _name,
        'department': _department,
        'profilePictureURL': url,
      });
      setState(() {
        _loading = false;
      });
      if (mounted) Navigator.of(context).pop({'updated': true});
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: _pickedImage != null
                        ? FileImage(
                            // ignore: use_build_context_synchronously
                            File(_pickedImage!.path),
                          )
                        : (_profilePictureURL != null
                                  ? NetworkImage(_profilePictureURL!)
                                  : null)
                              as ImageProvider<Object>?,
                    backgroundColor: Colors.grey[200],
                    child: (_profilePictureURL == null && _pickedImage == null)
                        ? const Icon(
                            Icons.account_circle,
                            size: 64,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 22,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter name' : null,
                onChanged: (v) => _name = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _department,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter department' : null,
                onChanged: (v) => _department = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.email,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_loading ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _AdminPanelScreenState.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditEventDialog extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> event;
  const _EditEventDialog({required this.docId, required this.event});
  @override
  State<_EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<_EditEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _organizerController;
  late TextEditingController _locationController;
  DateTime? _eventDate;
  TimeOfDay? _eventTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(
      text: widget.event['eventName'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.event['description'] ?? '',
    );
    _organizerController = TextEditingController(
      text: widget.event['organizer'] ?? '',
    );
    _locationController = TextEditingController(
      text: widget.event['locationID'] ?? '',
    );
    final ts = widget.event['eventDate'];
    if (ts is Timestamp) {
      _eventDate = ts.toDate();
    }
    final timeStr = widget.event['eventTime'] as String?;
    if (timeStr != null && timeStr.contains(':')) {
      final parts = timeStr.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1].split(' ')[0]) ?? 0;
      _eventTime = TimeOfDay(hour: hour, minute: minute);
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _organizerController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _eventDate == null ||
        _eventTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select date/time.'),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('campusEvents')
          .doc(widget.docId)
          .update({
            'eventName': _eventNameController.text.trim(),
            'description': _descriptionController.text.trim(),
            'eventDate': Timestamp.fromDate(_eventDate!),
            'eventTime': _eventTime!.format(context),
            'locationID': _locationController.text.trim(),
            'organizer': _organizerController.text.trim(),
          });
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update event: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter event name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _organizerController,
                decoration: const InputDecoration(labelText: 'Organizer'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter organizer' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter location name'
                    : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _eventDate == null
                      ? 'Select Event Date'
                      : 'Date: \\${_eventDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _eventDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _eventDate = picked);
                },
              ),
              ListTile(
                title: Text(
                  _eventTime == null
                      ? 'Select Event Time'
                      : 'Time: \\${_eventTime!.format(context)}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _eventTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _eventTime = picked);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
