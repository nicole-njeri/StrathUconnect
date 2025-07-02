import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strathapp/services/database_service.dart';

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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Onboarding Checklists'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Templates'),
              Tab(text: 'Student Progress'),
              Tab(text: 'Assign Checklists'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTemplatesTab(),
            _buildStudentProgressTab(),
            _buildAssignChecklistsTab(),
          ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildStudentProgressTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('onboardingChecklists')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final checklists = snapshot.data?.docs ?? [];
        if (checklists.isEmpty) {
          return const Center(child: Text('No student checklists found.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: checklists.length,
          separatorBuilder: (context, i) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final checklist = checklists[i];
            final data = checklist.data() as Map<String, dynamic>;
            return _buildStudentProgressCard(checklist.id, data);
          },
        );
      },
    );
  }

  Widget _buildStudentProgressCard(
    String studentId,
    Map<String, dynamic> data,
  ) {
    final completedTasks = data['completedTasks'] ?? 0;
    final totalTasks = data['totalTasks'] ?? 0;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
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
                    'Student ID: $studentId',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('$completedTasks/$totalTasks'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('Template: ${data['templateName'] ?? ''}'),
            if (data['lastUpdated'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Last updated: ${(data['lastUpdated'] as Timestamp).toDate().toString().substring(0, 16)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssignChecklistsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assign Checklist Template to Student',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('checklistTemplates')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final templates = snapshot.data?.docs ?? [];
                      if (templates.isEmpty) {
                        return const Center(
                          child: Text('No templates available.'),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Template',
                          border: OutlineInputBorder(),
                        ),
                        items: templates.map((template) {
                          final data = template.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: template.id,
                            child: Text(data['templateName'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          // Store selected template for assignment
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'student')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final students = snapshot.data?.docs ?? [];
                      if (students.isEmpty) {
                        return const Center(child: Text('No students found.'));
                      }
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Student',
                          border: OutlineInputBorder(),
                        ),
                        items: students.map((student) {
                          final data = student.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: student.id,
                            child: Text(
                              data['fullName'] ?? data['email'] ?? '',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          // Store selected student for assignment
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement assignment logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assignment feature coming soon!'),
                  ),
                );
              },
              child: const Text('Assign Checklist'),
            ),
          ),
        ],
      ),
    );
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
