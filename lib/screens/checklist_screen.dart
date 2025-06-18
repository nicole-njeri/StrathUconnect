import 'package:flutter/material.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<bool> freshmanEssentials = [false, false, false, false];
  List<bool> academicMilestones = [false, false];
  List<bool> campusLife = [false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Checklist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF1A3C7C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              'Freshman Year Essentials',
              [
                'Get your Student ID Card from the Admissions Office.',
                'Register for your first semester classes on the student portal.',
                'Attend the campus orientation and tour.',
                'Set up your university email and Wi-Fi on your devices.',
              ],
              freshmanEssentials,
              (i, val) => setState(() => freshmanEssentials[i] = val),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Academic Milestones',
              [
                'Schedule your first meeting with your academic advisor.',
                'Attend a library research skills workshop.',
              ],
              academicMilestones,
              (i, val) => setState(() => academicMilestones[i] = val),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Campus Life & Engagement',
              [
                'Explore and join at least one student club or society.',
                'Attend a university career fair.',
              ],
              campusLife,
              (i, val) => setState(() => campusLife[i] = val),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Checklist tab
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Checklist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          // TODO: Implement navigation if needed
        },
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> items,
    List<bool> values,
    Function(int, bool) onChanged,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...List.generate(items.length, (i) {
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(items[i]),
                value: values[i],
                onChanged: (val) => onChanged(i, val!),
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
          ],
        ),
      ),
    );
  }
}
