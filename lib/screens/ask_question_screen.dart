import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'question_detail_screen.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;

  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final user = _authService.currentUser;
      await FirebaseFirestore.instance.collection('questions').add({
        'question': _questionController.text.trim(),
        'userId': user?.uid,
        'userEmail': user?.email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _questionController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Question submitted!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit question: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2B6B),
        title: const Text('Ask a Question'),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6EEDD),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        labelText: 'Type your question...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a question';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      backgroundColor: const Color(0xFF0A2B6B),
                    ),
                    onPressed: _isSubmitting ? null : _submitQuestion,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('questions')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No questions yet.'));
                  }
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, i) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      return Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuestionDetailScreen(
                                  questionId: docs[i].id,
                                  questionText: data['question'] ?? '',
                                  askedBy: data['userEmail'] ?? 'Anonymous',
                                  timestamp:
                                      (data['timestamp'] as Timestamp?)
                                          ?.toDate() ??
                                      DateTime.now(),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['question'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Color(0xFF0A2B6B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data['userEmail'] ?? 'Anonymous',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    data['timestamp'] != null
                                        ? Text(
                                            (data['timestamp'] as Timestamp)
                                                .toDate()
                                                .toLocal()
                                                .toString()
                                                .substring(0, 16),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
