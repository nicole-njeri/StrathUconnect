import 'package:flutter/material.dart';
import 'package:strathapp/screens/admin/user_management_screen.dart';
import 'package:strathapp/screens/admin/create_event_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strathapp/services/auth_service.dart';
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
import 'package:strathapp/services/database_service.dart';

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
          _buildNavTile(
            icon: Icons.dashboard,
            label: 'Dashboard',
            index: 0,
          ),
          _buildNavTile(
            icon: Icons.people,
            label: 'User Management',
            index: 1,
          ),
          _buildNavTile(
            icon: Icons.event,
            label: 'Events Management',
            index: 2,
          ),
          _buildNavTile(
            icon: Icons.forum,
            label: 'Forum Management',
            index: 3,
          ),
          _buildNavTile(
            icon: Icons.checklist,
            label: 'Onboarding Checklists',
            index: 4,
          ),
          _buildNavTile(
            icon: Icons.notifications,
            label: 'Notifications Management',
            index: 5,
          ),
          _buildNavTile(
            icon: Icons.bar_chart,
            label: 'Reports',
            index: 6,
          ),
          _buildNavTile(
            icon: Icons.support_agent,
            label: 'FAQs and Feedback',
            index: 7,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({required IconData icon, required String label, required int index}) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: Container(
        color: _hoveredIndex == index
            ? Colors.blue.withOpacity(0.08)
            : (_selectedPageIndex == index ? Colors.blue.withOpacity(0.12) : null),
        child: ListTile(
          leading: Icon(icon, color: primaryBlue),
          title: Text(label, style: TextStyle(color: primaryBlue)),
          onTap: () => _selectPage(index),
          selected: _selectedPageIndex == index,
        ),
      ),
    );
  }

  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _DashboardScreen(adminNameFuture: _authService.getUserFullName()),
      const UserManagementScreen(),
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
      'Events Management',
      'Forum Management',
      'Onboarding Checklists',
      'Notifications Management',
      'Reports',
      'FAQs and Feedback',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6EEDD),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                height: 32,
                width: 32,
                child: StrathmoreLogo(size: 32),
              ),
            ),
            Expanded(
              child: Text(
                titles[_selectedPageIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
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
      // Removed drawer
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
    final DatabaseService _db = DatabaseService();
    return FutureBuilder<Map<String, dynamic>>(
      future: _db.getAdminDashboardStats(),
      builder: (context, statsSnapshot) {
        final stats = statsSnapshot.data ?? {};
        return FutureBuilder<String?>(
          future: adminNameFuture,
          builder: (context, nameSnapshot) {
            String adminName = 'Admin';
            if (nameSnapshot.hasData && nameSnapshot.data != null && nameSnapshot.data!.isNotEmpty) {
              adminName = nameSnapshot.data!.split(' ')[0];
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Hi $adminName 👋',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A2B6B),
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Summary Cards Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.people,
                            label: 'Total Users',
                            value: stats['totalStudents']?.toString() ?? '[X]',
                            color: Color(0xFFEAF3FF),
                            iconColor: Color(0xFF0A2B6B),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.event,
                            label: 'Active Events',
                            value: stats['activeEvents']?.toString() ?? '[Y]',
                            color: Color(0xFFEAF3FF),
                            iconColor: Color(0xFF0A2B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Grid of Action Cards
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _AdminActionCard(
                          icon: Icons.people,
                          label: 'User Management',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                          ),
                        ),
                        _AdminActionCard(
                          icon: Icons.event,
                          label: 'Events Management',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ManageEventsScreen()),
                          ),
                        ),
                        _AdminActionCard(
                          icon: Icons.forum,
                          label: 'Forum Management',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ForumModerationScreen()),
                          ),
                        ),
                        _AdminActionCard(
                          icon: Icons.checklist,
                          label: 'Onboarding Checklists',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ChecklistManagementScreen()),
                          ),
                        ),
                        _AdminActionCard(
                          icon: Icons.notifications,
                          label: 'Notifications Management',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NotificationManagementScreen()),
                          ),
                        ),
                        _AdminActionCard(
                          icon: Icons.bar_chart,
                          label: 'Reports',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ReportsScreen()),
                          ),
                        ),
                        _AdminActionCard(
                          icon: Icons.support_agent,
                          label: 'FAQs and Feedback',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SupportFeedbackScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconColor;
  const _SummaryCard({required this.icon, required this.label, required this.value, required this.color, required this.iconColor});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AdminActionCard({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFEAF3FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Color(0xFF0A2B6B)),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
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
      appBar: AppBar(
        backgroundColor: _AdminPanelScreenState.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Manage Events',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateEventScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
        backgroundColor: _AdminPanelScreenState.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  return Center(child: Text('Error: \\${snapshot.error}'));
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
                      color: Colors.white,
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
                              Text('Time: \\${eventTime}'),
                              Text('Location: \\${locationID}'),
                              Text('Organizer: \\${organizer}'),
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
  final String? initialProfilePictureURL;
  final String email;

  const _AdminProfileEditModal({
    required this.uid,
    required this.initialName,
    required this.initialProfilePictureURL,
    required this.email,
  });

  @override
  State<_AdminProfileEditModal> createState() => _AdminProfileEditModalState();
}

class _AdminProfileEditModalState extends State<_AdminProfileEditModal> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _profileImage;
  XFile? _pickedImage;
  bool _isEditing = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.email);
    // If you want to support initial profile image from URL, handle it in build
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _pickedImage = pickedFile;
      });
    }
  }

  Future<String?> _uploadImage(String uid) async {
    if (_pickedImage == null) return widget.initialProfilePictureURL;
    final ref = FirebaseStorage.instance.ref().child(
      'admin_profile_images/$uid.jpg',
    );
    await ref.putData(await _pickedImage!.readAsBytes());
    return await ref.getDownloadURL();
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = widget.uid;
      if (uid == null) throw Exception('User not found');
      final url = await _uploadImage(uid);
      await FirebaseFirestore.instance.collection('admins').doc(uid).update({
        'fullName': _nameController.text.trim(),
        'profilePictureURL': url,
      });
      setState(() {
        _loading = false;
        _isEditing = false;
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
      child: Center(
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFF6EEDD),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _isEditing ? _pickImage : null,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF0A2B6B),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (widget.initialProfilePictureURL != null
                            ? NetworkImage(widget.initialProfilePictureURL!)
                            : null) as ImageProvider<Object>?,
                    child: _profileImage == null && widget.initialProfilePictureURL == null
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: _isEditing ? Colors.white : Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isEditing)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A2B6B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        child: const Text('Edit'),
                      ),
                    if (_isEditing)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A2B6B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _loading ? null : _save,
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    if (_isEditing) const SizedBox(width: 12),
                    if (_isEditing)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0A2B6B)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                  ],
                ),
              ],
            ),
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
                      : 'Date: ${_eventDate!.toLocal().toString().split(' ')[0]}',
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
                      : 'Time: ${_eventTime!.format(context)}',
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
