import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strathapp/services/database_service.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final DatabaseService _dbService = DatabaseService();

  void _showEditSheet(BuildContext context, Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['fullName']);
    final roleController = TextEditingController(text: userData['role']);
    final departmentController = TextEditingController(
      text: userData['department'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Wrap(
            children: [
              Text(
                'Edit User',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 10),
              if (userData['role'] == 'admin')
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: roleController.text,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['student', 'admin'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  roleController.text = newValue!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final updates = {
                    'fullName': nameController.text,
                    'role': roleController.text,
                  };
                  try {
                    await _dbService.updateUser(widget.userId, updates);

                    if (roleController.text == 'admin' &&
                        departmentController.text.isNotEmpty) {
                      await _dbService.updateAdminProfile(widget.userId, {
                        'department': departmentController.text,
                      });
                    }

                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User updated successfully!'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update user: $e')),
                      );
                    }
                  }
                },
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(child: Text('Failed to load user data.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String role = userData['role'] ?? 'N/A';
          final DateTime? createdAt = (userData['createdAt'] as Timestamp?)
              ?.toDate();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Full Name'),
                  subtitle: Text(
                    userData['fullName'] ?? 'N/A',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  title: const Text('Email'),
                  subtitle: Text(userData['email'] ?? 'N/A'),
                ),
                ListTile(title: const Text('Role'), subtitle: Text(role)),
                ListTile(
                  title: const Text('Account Created'),
                  subtitle: Text(createdAt?.toString() ?? 'N/A'),
                ),
                const Divider(height: 32),
                if (role == 'admin')
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('admins')
                        .doc(widget.userId)
                        .get(),
                    builder: (context, adminSnapshot) {
                      if (!adminSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final adminData =
                          adminSnapshot.data!.data() as Map<String, dynamic>?;
                      return ListTile(
                        title: const Text('Department'),
                        subtitle: Text(adminData?['department'] ?? 'N/A'),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Update Details'),
                  onPressed: () => _showEditSheet(context, userData),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
