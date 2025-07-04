import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strathapp/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({super.key});

  @override
  State<NotificationManagementScreen> createState() =>
      _NotificationManagementScreenState();
}

class _NotificationManagementScreenState
    extends State<NotificationManagementScreen> {
  final DatabaseService _db = DatabaseService();
  final user = FirebaseAuth.instance.currentUser;
  final int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _createDefaultTemplatesIfNeeded();
  }

  Future<void> _createDefaultTemplatesIfNeeded() async {
    final templates = await _db.getAllNotificationTemplates();
    if (templates.isEmpty) {
      // Create default templates
      await _db.createNotificationTemplate(
        templateName: 'General Announcement',
        title: 'Important Announcement',
        message: 'This is a general announcement for all students.',
        type: 'general',
        priority: 'medium',
      );
      await _db.createNotificationTemplate(
        templateName: 'Event Reminder',
        title: 'Event Reminder',
        message: 'Don\'t forget about the upcoming event!',
        type: 'event',
        priority: 'medium',
      );
      await _db.createNotificationTemplate(
        templateName: 'Academic Alert',
        title: 'Academic Alert',
        message: 'Important academic information for students.',
        type: 'academic',
        priority: 'high',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Send Notifications'),
          bottom: const TabBar(
            indicatorColor: Color(0xFF003399),
            labelColor: Color(0xFF003399),
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Send Notification'),
              Tab(text: 'Templates'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSendNotificationTab(),
            _buildTemplatesTab(),
            _buildAnalyticsTab(),
          ],
        ),
        floatingActionButton: _selectedTabIndex == 1
            ? FloatingActionButton(
                onPressed: _showCreateTemplateDialog,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildSendNotificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Notification',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildNotificationForm(),
        ],
      ),
    );
  }

  Widget _buildNotificationForm() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'general';
    String selectedPriority = 'medium';
    String selectedTarget = 'all';
    String? selectedCategory;
    String? selectedYear;

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Notification Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: messageController,
            decoration: const InputDecoration(
              labelText: 'Notification Message',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a message';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedType,
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(
                      value: 'academic',
                      child: Text('Academic'),
                    ),
                    DropdownMenuItem(value: 'event', child: Text('Event')),
                    DropdownMenuItem(
                      value: 'maintenance',
                      child: Text('Maintenance'),
                    ),
                    DropdownMenuItem(
                      value: 'security',
                      child: Text('Security'),
                    ),
                    DropdownMenuItem(value: 'library', child: Text('Library')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedType = value!);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedPriority,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedPriority = value!);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Target Audience',
              border: OutlineInputBorder(),
            ),
            value: selectedTarget,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Students')),
              DropdownMenuItem(value: 'year1', child: Text('Year 1')),
              DropdownMenuItem(value: 'year2', child: Text('Year 2')),
              DropdownMenuItem(value: 'year3', child: Text('Year 3')),
              DropdownMenuItem(value: 'year4', child: Text('Year 4')),
            ],
            onChanged: (value) {
              setState(() => selectedTarget = value!);
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    messageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                    ),
                  );
                  return;
                }

                try {
                  if (selectedTarget == 'all') {
                    await _db.sendNotificationToAllStudents(
                      title: titleController.text.trim(),
                      message: messageController.text.trim(),
                      type: selectedType,
                      priority: selectedPriority,
                      senderId: user?.uid,
                    );
                  } else if (selectedTarget == 'category') {
                    await _db.sendNotificationToStudentsByCategory(
                      title: titleController.text.trim(),
                      message: messageController.text.trim(),
                      type: selectedType,
                      priority: selectedPriority,
                      senderId: user?.uid,
                      category: selectedCategory,
                    );
                  } else if (selectedTarget == 'year') {
                    await _db.sendNotificationToStudentsByYear(
                      title: titleController.text.trim(),
                      message: messageController.text.trim(),
                      type: selectedType,
                      priority: selectedPriority,
                      senderId: user?.uid,
                      year: selectedYear,
                    );
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification sent successfully!'),
                    ),
                  );
                  titleController.clear();
                  messageController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error sending notification: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF003399),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
              child: const Text('Send Notification'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notificationTemplates')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final templates = snapshot.data?.docs ?? [];
        if (templates.isEmpty) {
          return const Center(child: Text('No templates found.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: templates.length,
          separatorBuilder: (context, i) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final template = templates[i];
            final data = template.data() as Map<String, dynamic>;
            return _buildTemplateCard(template.id, data);
          },
        );
      },
    );
  }

  Widget _buildTemplateCard(String templateId, Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data['templateName'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditTemplateDialog(templateId, data);
                    } else if (value == 'delete') {
                      _deleteTemplate(templateId);
                    } else if (value == 'use') {
                      _useTemplate(data);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'use',
                      child: Text('Use Template'),
                    ),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Title: ${data['title'] ?? ''}'),
            const SizedBox(height: 4),
            Text('Message: ${data['message'] ?? ''}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(label: Text(data['type'] ?? '')),
                const SizedBox(width: 8),
                Chip(
                  label: Text(data['priority'] ?? ''),
                  backgroundColor: _getPriorityColor(
                    data['priority'],
                  ).withOpacity(0.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _db.getNotificationStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final stats = snapshot.data ?? {};
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notification Analytics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Notifications',
                      '${stats['totalNotifications'] ?? 0}',
                      Icons.notifications,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Unread',
                      '${stats['unreadNotifications'] ?? 0}',
                      Icons.mark_email_unread,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Read',
                      '${stats['readNotifications'] ?? 0}',
                      Icons.mark_email_read,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _db.getRecentNotifications(limit: 5),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final notifications = snapshot.data ?? [];
                  if (notifications.isEmpty) {
                    return const Text('No recent notifications');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, i) {
                      final notification = notifications[i];
                      return ListTile(
                        title: Text(notification['title'] ?? ''),
                        subtitle: Text(notification['message'] ?? ''),
                        trailing: Chip(
                          label: Text(notification['type'] ?? ''),
                          backgroundColor: Colors.grey.withOpacity(0.2),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
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

  void _showCreateTemplateDialog() {
    final nameController = TextEditingController();
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'general';
    String selectedPriority = 'medium';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Notification Template'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Template Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Type'),
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: 'general',
                          child: Text('General'),
                        ),
                        DropdownMenuItem(
                          value: 'academic',
                          child: Text('Academic'),
                        ),
                        DropdownMenuItem(value: 'event', child: Text('Event')),
                      ],
                      onChanged: (value) => selectedType = value!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Priority'),
                      value: selectedPriority,
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                      ],
                      onChanged: (value) => selectedPriority = value!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  titleController.text.trim().isEmpty ||
                  messageController.text.trim().isEmpty) {
                return;
              }

              await _db.createNotificationTemplate(
                templateName: nameController.text.trim(),
                title: titleController.text.trim(),
                message: messageController.text.trim(),
                type: selectedType,
                priority: selectedPriority,
              );
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditTemplateDialog(
    String templateId,
    Map<String, dynamic> existing,
  ) {
    final nameController = TextEditingController(
      text: existing['templateName'] ?? '',
    );
    final titleController = TextEditingController(
      text: existing['title'] ?? '',
    );
    final messageController = TextEditingController(
      text: existing['message'] ?? '',
    );
    String selectedType = existing['type'] ?? 'general';
    String selectedPriority = existing['priority'] ?? 'medium';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Notification Template'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Template Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Type'),
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: 'general',
                          child: Text('General'),
                        ),
                        DropdownMenuItem(
                          value: 'academic',
                          child: Text('Academic'),
                        ),
                        DropdownMenuItem(value: 'event', child: Text('Event')),
                      ],
                      onChanged: (value) => selectedType = value!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Priority'),
                      value: selectedPriority,
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                      ],
                      onChanged: (value) => selectedPriority = value!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  titleController.text.trim().isEmpty ||
                  messageController.text.trim().isEmpty) {
                return;
              }

              await _db.updateNotificationTemplate(templateId, {
                'templateName': nameController.text.trim(),
                'title': titleController.text.trim(),
                'message': messageController.text.trim(),
                'type': selectedType,
                'priority': selectedPriority,
              });
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteTemplate(String templateId) async {
    await _db.deleteNotificationTemplate(templateId);
  }

  void _useTemplate(Map<String, dynamic> template) {
    // TODO: Implement template usage in the send notification form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Template usage feature coming soon!')),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
