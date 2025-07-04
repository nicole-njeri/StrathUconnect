import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuestionDetailScreen extends StatefulWidget {
  final String questionId;
  final String questionText;
  final String askedBy;
  final DateTime timestamp;

  const QuestionDetailScreen({
    Key? key,
    required this.questionId,
    required this.questionText,
    required this.askedBy,
    required this.timestamp,
  }) : super(key: key);

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
      appBar: AppBar(title: const Text('Question Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Asked by: ${widget.askedBy}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'At: ${widget.timestamp.toLocal().toString().substring(0, 16)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 32),
            const Text(
              'Answers:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['answer'] ?? ''),
                        subtitle: Text(data['answeredBy'] ?? ''),
                        trailing: data['timestamp'] != null
                            ? Text(
                                (data['timestamp'] as Timestamp)
                                    .toDate()
                                    .toLocal()
                                    .toString()
                                    .substring(0, 16),
                              )
                            : null,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerController,
                    decoration: const InputDecoration(
                      hintText: 'Type your answer...',
                    ),
                  ),
                ),
                IconButton(
                  icon: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: _isSubmitting ? null : _submitAnswer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
