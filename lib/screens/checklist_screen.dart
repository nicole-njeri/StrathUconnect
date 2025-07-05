import 'package:flutter/material.dart';
import 'package:strathapp/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final DatabaseService _db = DatabaseService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your checklist.')),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _db.getActiveChecklistTemplate(),
      builder: (context, templateSnapshot) {
        if (templateSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!templateSnapshot.hasData || templateSnapshot.data == null) {
          return _buildNoChecklistView();
        }
        final template = templateSnapshot.data!;
        final tasks = List<Map<String, dynamic>>.from(template['tasks'] ?? []);
        final templateName = template['templateName'] ?? '';
        return FutureBuilder<List<int>>(
          future: _db.getStudentChecklistProgress(user!.uid),
          builder: (context, progressSnapshot) {
            if (progressSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final completedIndexes = progressSnapshot.data ?? [];
            final completedTasks = completedIndexes.length;
            final totalTasks = tasks.length;
            final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'My Checklist',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: const Color(0xFF0A2B6B),
                elevation: 0,
              ),
              backgroundColor: const Color(0xFFF6EEDD),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Card
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF0A2B6B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF0A2B6B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ' $completedTasks of $totalTasks tasks completed',
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (templateName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Template: $templateName',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tasks
                    if (tasks.isNotEmpty) ...[
                      const Text(
                        'Tasks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF0A2B6B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...tasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final task = entry.value;
                        final isCompleted = completedIndexes.contains(index);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            elevation: 1,
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            child: CheckboxListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(
                                task['description'] ?? '',
                                style: TextStyle(
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isCompleted
                                      ? Colors.grey
                                      : const Color(0xFF0A2B6B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: isCompleted,
                              onChanged: (value) async {
                                final newIndexes = List<int>.from(
                                  completedIndexes,
                                );
                                if (value == true &&
                                    !newIndexes.contains(index)) {
                                  newIndexes.add(index);
                                } else if (value == false &&
                                    newIndexes.contains(index)) {
                                  newIndexes.remove(index);
                                }
                                await _db.setStudentChecklistProgress(
                                  user!.uid,
                                  newIndexes,
                                );
                                setState(() {});
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: const Color(0xFF0A2B6B),
                              checkColor: Colors.white,
                              tileColor: Colors.white,
                            ),
                          ),
                        );
                      }),
                    ] else ...[
                      const Center(
                        child: Text(
                          'No tasks assigned yet. Contact your administrator.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoChecklistView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_box_outline_blank,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Checklist Assigned',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your onboarding checklist has not been assigned yet.\nPlease contact your administrator.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Refresh the stream
              setState(() {});
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
