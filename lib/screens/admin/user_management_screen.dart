import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strathapp/screens/admin/user_detail_screen.dart';
import 'package:strathapp/screens/admin_panel_screen.dart';
import 'package:strathapp/services/database_service.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final users = snapshot.data!.docs;

        return Scaffold(
          backgroundColor: const Color(0xFFF6EEDD),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A2B6B),
            title: const Text(
              'User Management',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                  (route) => false,
                );
              },
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;

              // Safely access fields with fallback values
              final String fullName = userData['fullName'] ?? 'N/A';
              final String email = userData['email'] ?? 'N/A';
              final String role = userData['role'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    child: Text(
                      role == 'admin' ? 'A' : 'S',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  title: Text(
                    fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$email\nRole: $role'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'view_details') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDetailScreen(userId: user.id),
                          ),
                        );
                      } else if (value == 'ban') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Ban User'),
                            content: Text('Are you sure you want to ban $fullName?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Ban'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await DatabaseService().banUser(user.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$fullName has been banned.'),
                            ),
                          );
                        }
                      } else {
                        // TODO: Implement other actions ('promote', 'demote', etc.)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Action "$value" selected for $fullName',
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'view_details',
                            child: Text('View Details'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'ban',
                            child: Text('Ban User'),
                          ),
                          if (role == 'student')
                            const PopupMenuItem<String>(
                              value: 'promote_admin',
                              child: Text('Make Admin'),
                            ),
                          if (role == 'admin')
                            const PopupMenuItem<String>(
                              value: 'demote_student',
                              child: Text('Make Student'),
                            ),
                        ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
