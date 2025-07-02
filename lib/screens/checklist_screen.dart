import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Checklist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF1A3C7C),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('onboardingChecklists')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildNoChecklistView();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final tasks = List<Map<String, dynamic>>.from(data['tasks'] ?? []);
          final completedTasks = data['completedTasks'] ?? 0;
          final totalTasks = data['totalTasks'] ?? 0;
          final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
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
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF1A3C7C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completedTasks of $totalTasks tasks completed',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (data['templateName'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Template: ${data['templateName']}',
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ...tasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final task = entry.value;
                    final isCompleted = task['isCompleted'] == true;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                      child: CheckboxListTile(
                        title: Text(
                          task['description'] ?? '',
                          style: TextStyle(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted ? Colors.grey : null,
                          ),
                        ),
                        value: isCompleted,
                        onChanged: (value) async {
                          await _db.updateTaskStatus(
                            user!.uid,
                            index,
                            value ?? false,
                          );
                        },
                        controlAffinity: ListTileControlAffinity.leading,
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
                const SizedBox(height: 16),
                // Last Updated
                if (data['lastUpdated'] != null) ...[
                  Text(
                    'Last updated: ${(data['lastUpdated'] as Timestamp).toDate().toString().substring(0, 16)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ],
            ),
          );
        },
      ),
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
