import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strathapp/services/database_service.dart';
import 'package:strathapp/screens/admin_panel_screen.dart';

class ChecklistManagementScreen extends StatefulWidget {
  const ChecklistManagementScreen({super.key});

  @override
  State<ChecklistManagementScreen> createState() =>
      _ChecklistManagementScreenState();
}

class _ChecklistManagementScreenState extends State<ChecklistManagementScreen> {
  final DatabaseService _db = DatabaseService();
  final int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _createDefaultTemplateIfNeeded();
  }

  Future<void> _createDefaultTemplateIfNeeded() async {
    final templates = await _db.getAllChecklistTemplates();
    if (templates.isEmpty) {
      // Create a default template
      await _db.createChecklistTemplate(
        templateName: 'Freshman Orientation Checklist',
        description:
            'Essential tasks for new students to complete during their first semester',
        tasks: [
          {
            'description':
                'Get your Student ID Card from the Admissions Office',
          },
          {
            'description':
                'Register for your first semester classes on the student portal',
          },
          {'description': 'Attend the campus orientation and tour'},
          {
            'description':
                'Set up your university email and Wi-Fi on your devices',
          },
          {
            'description':
                'Schedule your first meeting with your academic advisor',
          },
          {'description': 'Attend a library research skills workshop'},
          {
            'description':
                'Explore and join at least one student club or society',
          },
          {'description': 'Attend a university career fair'},
          {'description': 'Complete the student handbook quiz'},
          {
            'description':
                'Set up your student portal account and explore available resources',
          },
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6EEDD),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A2B6B),
          title: const Text(
            'Onboarding Checklists',
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Templates'),
              Tab(text: 'Student Progress'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildTemplatesTab(), _buildStudentProgressTab()],
        ),
        floatingActionButton: _selectedTabIndex == 0
            ? FloatingActionButton(
                onPressed: _showCreateTemplateDialog,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('checklistTemplates')
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
    final tasks = List<Map<String, dynamic>>.from(data['tasks'] ?? []);
    final isActive = data['isActive'] == true;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                if (isActive)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(
                        'Active',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: Colors.green,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditTemplateDialog(templateId, data);
                    } else if (value == 'delete') {
                      _deleteTemplate(templateId);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            if (data['description'] != null) ...[
              const SizedBox(height: 4),
              Text(
                data['description'] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 8),
            Text('${tasks.length} tasks'),
            const SizedBox(height: 8),
            ...tasks
                .take(3)
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text('• ${task['description'] ?? ''}'),
                  ),
                ),
            if (tasks.length > 3)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text('... and ${tasks.length - 3} more tasks'),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: isActive
                      ? null
                      : () async {
                          // Set this template as active, unset all others
                          final batch = FirebaseFirestore.instance.batch();
                          final templates = await FirebaseFirestore.instance
                              .collection('checklistTemplates')
                              .get();
                          for (final doc in templates.docs) {
                            batch.update(doc.reference, {
                              'isActive': doc.id == templateId,
                            });
                          }
                          await batch.commit();
                          setState(() {});
                        },
                  icon: const Icon(Icons.check_circle),
                  label: Text(isActive ? 'Active' : 'Set Active'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? Colors.green : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentProgressTab() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        }
        final students = userSnapshot.data?.docs ?? [];
        if (students.isEmpty) {
          return const Center(child: Text('No students found.'));
        }
        return FutureBuilder<Map<String, dynamic>>(
          future: _getActiveTemplateAndProgress(students),
          builder: (context, progressSnapshot) {
            if (progressSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (progressSnapshot.hasError) {
              return Center(child: Text('Error: ${progressSnapshot.error}'));
            }
            final data = progressSnapshot.data ?? {};
            final template = data['template'] as Map<String, dynamic>?;
            final progressList = data['progressList'] as List<dynamic>? ?? [];
            if (progressList.isEmpty) {
              return const Center(child: Text('No student progress found.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: progressList.length,
              separatorBuilder: (context, i) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = progressList[i];
                final student = item['student'] as Map<String, dynamic>;
                final completed = item['completed'] as int;
                final total = item['total'] as int;
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['fullName'] ?? student['email'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          student['email'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: total > 0 ? completed / total : 0.0,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF1A3C7C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('$completed of $total tasks completed'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getActiveTemplateAndProgress(
    List studentDocs,
  ) async {
    final templateSnap = await FirebaseFirestore.instance
        .collection('checklistTemplates')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    final template = templateSnap.docs.isNotEmpty
        ? templateSnap.docs.first.data()
        : null;
    final totalTasks = template != null && template['tasks'] is List
        ? (template['tasks'] as List).length
        : 0;
    final progressList = <Map<String, dynamic>>[];
    for (final doc in studentDocs) {
      final student = doc.data() as Map<String, dynamic>;
      final progressSnap = await FirebaseFirestore.instance
          .collection('onboardingProgress')
          .doc(doc.id)
          .get();
      final completedIndexes =
          progressSnap.exists &&
              progressSnap.data()?['completedTaskIndexes'] is List
          ? (progressSnap.data()!['completedTaskIndexes'] as List)
          : [];
      progressList.add({
        'student': student,
        'completed': completedIndexes.length,
        'total': totalTasks,
      });
    }
    return {'template': template, 'progressList': progressList};
  }

  void _showCreateTemplateDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final List<Map<String, dynamic>> tasks = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Checklist Template'),
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
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tasks:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...tasks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final task = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Task ${index + 1}',
                            ),
                            onChanged: (value) => task['description'] = value,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() => tasks.removeAt(index));
                          },
                        ),
                      ],
                    ),
                  );
                }),
                TextButton(
                  onPressed: () {
                    setState(() => tasks.add({'description': ''}));
                  },
                  child: const Text('Add Task'),
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
                if (nameController.text.trim().isEmpty || tasks.isEmpty) return;
                final validTasks = tasks
                    .where(
                      (task) =>
                          task['description'].toString().trim().isNotEmpty,
                    )
                    .toList();
                if (validTasks.isEmpty) return;

                await _db.createChecklistTemplate(
                  templateName: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  tasks: validTasks,
                );
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
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
    final descriptionController = TextEditingController(
      text: existing['description'] ?? '',
    );
    final List<Map<String, dynamic>> tasks = List.from(existing['tasks'] ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Checklist Template'),
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
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tasks:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...tasks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final task = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Task ${index + 1}',
                            ),
                            controller: TextEditingController(
                              text: task['description'] ?? '',
                            ),
                            onChanged: (value) => task['description'] = value,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() => tasks.removeAt(index));
                          },
                        ),
                      ],
                    ),
                  );
                }),
                TextButton(
                  onPressed: () {
                    setState(() => tasks.add({'description': ''}));
                  },
                  child: const Text('Add Task'),
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
                if (nameController.text.trim().isEmpty || tasks.isEmpty) return;
                final validTasks = tasks
                    .where(
                      (task) =>
                          task['description'].toString().trim().isNotEmpty,
                    )
                    .toList();
                if (validTasks.isEmpty) return;

                await _db.updateChecklistTemplate(templateId, {
                  'templateName': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'tasks': validTasks,
                });
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTemplate(String templateId) async {
    await _db.deleteChecklistTemplate(templateId);
  }
}
