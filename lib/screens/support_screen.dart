import 'package:flutter/material.dart';
import 'package:strathapp/services/database_service.dart';
import 'package:strathapp/services/auth_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6EEDD),
        appBar: AppBar(
          title: const Text('FAQs and Feedback'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'FAQs'),
              Tab(text: 'Feedback'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFAQTab(),
            _buildFeedbackTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search FAQs',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {}); // Trigger rebuild for search
            },
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
                return question.contains(searchTerm) ||
                    answer.contains(searchTerm);
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
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _rateFAQ(faq['id'], true),
                                      icon: const Icon(Icons.thumb_up),
                                      label: Text(
                                        'Helpful (${faq['helpfulCount'] ?? 0})',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _rateFAQ(faq['id'], false),
                                      icon: const Icon(Icons.thumb_down),
                                      label: Text(
                                        'Not Helpful (${faq['notHelpfulCount'] ?? 0})',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
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

  Widget _buildFeedbackTab() {
    final messageController = TextEditingController();
    String selectedType = 'general';
    String selectedCategory = 'General';
    int rating = 5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Submit Feedback',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'We value your feedback! Help us improve the app by sharing your thoughts, suggestions, or reporting issues.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: const InputDecoration(
              labelText: 'Feedback Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'general',
                child: Text('General Feedback'),
              ),
              DropdownMenuItem(
                value: 'feature_request',
                child: Text('Feature Request'),
              ),
              DropdownMenuItem(value: 'bug_report', child: Text('Bug Report')),
              DropdownMenuItem(value: 'faq_rating', child: Text('FAQ Rating')),
            ],
            onChanged: (value) {
              selectedType = value!;
            },
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
              DropdownMenuItem(value: 'UI/UX', child: Text('UI/UX')),
              DropdownMenuItem(
                value: 'Functionality',
                child: Text('Functionality'),
              ),
              DropdownMenuItem(
                value: 'Performance',
                child: Text('Performance'),
              ),
            ],
            onChanged: (value) {
              selectedCategory = value!;
            },
          ),
          const SizedBox(height: 16),
          const Text('Rating (optional):'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    rating = index + 1;
                  });
                },
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: messageController,
            decoration: const InputDecoration(
              labelText: 'Your Feedback',
              border: OutlineInputBorder(),
              hintText:
                  'Please share your thoughts, suggestions, or report any issues...',
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (messageController.text.isNotEmpty) {
                  try {
                    await _db.submitFeedback(
                      userId: _auth.currentUser?.uid ?? '',
                      userEmail: _auth.currentUser?.email ?? '',
                      feedbackType: selectedType,
                      message: messageController.text,
                      rating: rating,
                      category: selectedCategory,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feedback submitted successfully!'),
                      ),
                    );
                    messageController.clear();
                    setState(() {
                      rating = 5;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error submitting feedback: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter your feedback')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Submit Feedback'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rateFAQ(String faqId, bool isHelpful) async {
    try {
      await _db.rateFAQ(faqId, isHelpful);
      setState(() {}); // Refresh the UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error rating FAQ: $e')));
    }
  }
}
