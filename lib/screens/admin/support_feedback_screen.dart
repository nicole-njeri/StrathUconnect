import 'package:flutter/material.dart';
import 'package:strathapp/services/database_service.dart';
import 'package:strathapp/services/auth_service.dart';
import 'package:strathapp/screens/admin_panel_screen.dart';

class SupportFeedbackScreen extends StatefulWidget {
  const SupportFeedbackScreen({super.key});

  @override
  State<SupportFeedbackScreen> createState() => _SupportFeedbackScreenState();
}

class _SupportFeedbackScreenState extends State<SupportFeedbackScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  String _selectedTicketStatus = 'all';
  String _selectedFeedbackStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6EEDD),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A2B6B),
          title: const Text(
            'Support & Feedback',
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
              Tab(text: 'FAQs'),
              Tab(text: 'Support Tickets'),
              Tab(text: 'Feedback'),
              Tab(text: 'Analytics'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.data_usage, color: Colors.white),
              tooltip: 'Generate Dummy Data',
              onPressed: _generateDummyData,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildFAQsTab(),
            _buildSupportTicketsTab(),
            _buildFeedbackTab(),
            _buildAnalyticsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTicketsTab() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _db.getSupportTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) {
            return const Center(child: Text('No support tickets found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text(
                    ticket['subject'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From: ${ticket['userEmail'] ?? ''}'),
                      Text('Category: ${ticket['category'] ?? ''}'),
                      Text('Status: ${ticket['status'] ?? ''}'),
                      Text('Priority: ${ticket['priority'] ?? ''}'),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(ticket['description'] ?? ''),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateTicketStatus(
                                    ticket['id'],
                                    'in_progress',
                                  ),
                                  child: const Text('Mark In Progress'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateTicketStatus(
                                    ticket['id'],
                                    'resolved',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Resolve'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showResponseDialog(ticket),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Add Response'),
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
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _db.getFeedback(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final feedback = snapshot.data ?? [];
          if (feedback.isEmpty) {
            return const Center(child: Text('No feedback found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: feedback.length,
            itemBuilder: (context, index) {
              final item = feedback[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text(
                    '${item['feedbackType'] ?? ''} - ${item['category'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From: ${item['userEmail'] ?? ''}'),
                      Text('Status: ${item['status'] ?? ''}'),
                      if (item['rating'] != null)
                        Text('Rating: ${item['rating']}/5'),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Message:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(item['message'] ?? ''),
                          if (item['adminResponse'] != null) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Admin Response:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(item['adminResponse']),
                          ],
                          const SizedBox(height: 16),
                          if (item['status'] == 'pending')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _showFeedbackResponseDialog(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Respond to Feedback'),
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
      ),
    );
  }

  Widget _buildFAQsTab() {
    final TextEditingController _searchController = TextEditingController();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search FAQs',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showAddFAQDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add FAQ'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _generateDummyFAQs,
                icon: const Icon(Icons.refresh),
                label: const Text('Seed Dummy FAQs'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _db.getFAQs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final faqs = snapshot.data ?? [];
              // Filter by search term
              final filteredFaqs = faqs.where((faq) {
                final searchTerm = _searchController.text.toLowerCase();
                final question = (faq['question'] ?? '').toLowerCase();
                final answer = (faq['answer'] ?? '').toLowerCase();
                return question.contains(searchTerm) || answer.contains(searchTerm);
              }).toList();
              if (filteredFaqs.isEmpty) {
                return const Center(child: Text('No FAQs found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredFaqs.length > 6 ? 6 : filteredFaqs.length,
                itemBuilder: (context, index) {
                  final faq = filteredFaqs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      title: Text(
                        faq['question'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: ${faq['category'] ?? ''}'),
                          Text(
                            'Helpful: ${faq['helpfulCount'] ?? 0} | Not Helpful: ${faq['notHelpfulCount'] ?? 0}',
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Answer:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(faq['answer'] ?? ''),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _showEditFAQDialog(faq),
                                      child: const Text('Edit'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _deleteFAQ(faq['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ),
                                ],
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
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _db.getSupportAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final analytics = snapshot.data ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Support Analytics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAnalyticsCard(
                      'Total Tickets',
                      '${analytics['totalTickets'] ?? 0}',
                      Icons.support_agent,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAnalyticsCard(
                      'Open Tickets',
                      '${analytics['openTickets'] ?? 0}',
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAnalyticsCard(
                      'Resolved Tickets',
                      '${analytics['resolvedTickets'] ?? 0}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAnalyticsCard(
                      'Total Feedback',
                      '${analytics['totalFeedback'] ?? 0}',
                      Icons.feedback,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAnalyticsCard(
                      'Pending Feedback',
                      '${analytics['pendingFeedback'] ?? 0}',
                      Icons.schedule,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAnalyticsCard(
                      'Active FAQs',
                      '${analytics['activeFAQs'] ?? 0}',
                      Icons.help,
                      Colors.indigo,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsCard(
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateTicketStatus(String ticketId, String status) async {
    try {
      await _db.updateTicketStatus(ticketId, status);
      setState(() {}); // Refresh the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket status updated to $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating ticket status: $e')),
      );
    }
  }

  Future<void> _showResponseDialog(Map<String, dynamic> ticket) async {
    final responseController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Response'),
        content: TextField(
          controller: responseController,
          decoration: const InputDecoration(
            labelText: 'Response',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.isNotEmpty) {
                await _db.addTicketResponse(
                  ticket['id'],
                  responderId: _auth.currentUser?.uid ?? '',
                  responderName: 'Admin',
                  message: responseController.text,
                  isAdmin: true,
                );
                Navigator.pop(context);
                setState(() {}); // Refresh the UI
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Response added successfully')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFeedbackResponseDialog(
    Map<String, dynamic> feedback,
  ) async {
    final responseController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respond to Feedback'),
        content: TextField(
          controller: responseController,
          decoration: const InputDecoration(
            labelText: 'Admin Response',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.isNotEmpty) {
                await _db.updateFeedbackStatus(
                  feedback['id'],
                  'reviewed',
                  adminResponse: responseController.text,
                );
                Navigator.pop(context);
                setState(() {}); // Refresh the UI
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback response sent')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddFAQDialog() async {
    final questionController = TextEditingController();
    final answerController = TextEditingController();
    String selectedCategory = 'General';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add FAQ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'General', child: Text('General')),
                DropdownMenuItem(value: 'Account', child: Text('Account')),
                DropdownMenuItem(value: 'Events', child: Text('Events')),
                DropdownMenuItem(value: 'Forum', child: Text('Forum')),
                DropdownMenuItem(value: 'Technical', child: Text('Technical')),
              ],
              onChanged: (value) {
                selectedCategory = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (questionController.text.isNotEmpty &&
                  answerController.text.isNotEmpty) {
                await _db.createFAQ(
                  question: questionController.text,
                  answer: answerController.text,
                  category: selectedCategory,
                );
                Navigator.pop(context);
                setState(() {}); // Refresh the UI
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FAQ added successfully')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditFAQDialog(Map<String, dynamic> faq) async {
    final questionController = TextEditingController(text: faq['question']);
    final answerController = TextEditingController(text: faq['answer']);
    String selectedCategory = faq['category'] ?? 'General';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit FAQ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'General', child: Text('General')),
                DropdownMenuItem(value: 'Account', child: Text('Account')),
                DropdownMenuItem(value: 'Events', child: Text('Events')),
                DropdownMenuItem(value: 'Forum', child: Text('Forum')),
                DropdownMenuItem(value: 'Technical', child: Text('Technical')),
              ],
              onChanged: (value) {
                selectedCategory = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (questionController.text.isNotEmpty &&
                  answerController.text.isNotEmpty) {
                await _db.updateFAQ(
                  faq['id'],
                  question: questionController.text,
                  answer: answerController.text,
                  category: selectedCategory,
                );
                Navigator.pop(context);
                setState(() {}); // Refresh the UI
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FAQ updated successfully')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFAQ(String faqId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete FAQ'),
        content: const Text('Are you sure you want to delete this FAQ?'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _db.deleteFAQ(faqId);
        setState(() {}); // Refresh the UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FAQ deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting FAQ: $e')));
      }
    }
  }

  Future<void> _generateDummyData() async {
    try {
      await _db.generateDummySupportData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dummy support data generated successfully!'),
        ),
      );
      setState(() {}); // Refresh the UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating dummy data: $e')),
      );
    }
  }

  Future<void> _generateDummyFAQs() async {
    try {
      await _db.generateDummyFAQs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dummy FAQs generated!')),
        );
        setState(() {}); // Refresh the FAQ list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating FAQs: $e')),
        );
      }
    }
  }
}
