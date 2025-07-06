import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuestionDetailScreen extends StatefulWidget {
  final String questionId;
  final String questionText;
  final String askedBy;
  final DateTime timestamp;

  const QuestionDetailScreen({
    super.key,
    required this.questionId,
    required this.questionText,
    required this.askedBy,
    required this.timestamp,
  });

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitAnswer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _answerController.text.trim().isEmpty) return;
    setState(() {
      _isSubmitting = true;
    });
    await FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.questionId)
        .collection('answers')
        .add({
          'answer': _answerController.text.trim(),
          'answeredBy': user.email ?? 'Anonymous',
          'timestamp': FieldValue.serverTimestamp(),
        });
    _answerController.clear();
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2B6B),
        title: const Text(
          'Question Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6EEDD),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2B6B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Asked by: ${widget.askedBy}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            Text(
              'At: ${widget.timestamp.toLocal().toString().substring(0, 16)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Divider(height: 32),
            const Text(
              'Answers:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2B6B),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('questions')
                    .doc(widget.questionId)
                    .collection('answers')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text(
                      'No answers yet. Be the first to answer!',
                    );
                  }
                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, i) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final doc = snapshot.data!.docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      return Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['answer'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
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
                                    data['answeredBy'] ?? '',
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
                                  IconButton(
                                    icon: const Icon(
                                      Icons.flag,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    tooltip: 'Report',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Report Answer'),
                                          content: const Text(
                                            'Feature coming soon.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      hintText: 'Type your answer...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: const Color(0xFF0A2B6B),
                  ),
                  onPressed: _isSubmitting ? null : _submitAnswer,
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
          ],
        ),
      ),
    );
  }
}
