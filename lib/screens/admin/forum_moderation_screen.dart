import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strathapp/services/database_service.dart';
import 'package:strathapp/screens/admin_panel_screen.dart';

class ForumModerationScreen extends StatefulWidget {
  const ForumModerationScreen({super.key});

  @override
  State<ForumModerationScreen> createState() => _ForumModerationScreenState();
}

class _ForumModerationScreenState extends State<ForumModerationScreen> {
  final DatabaseService _db = DatabaseService();
  String? _selectedCategory;
  bool _showFlagged = false;
  bool _showPinned = false;
  bool _showReports = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EEDD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2B6B),
        title: const Text(
          'Forum Management',
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
        actions: [
          IconButton(
            icon: Icon(_showReports ? Icons.flag : Icons.outlined_flag),
            tooltip: _showReports ? 'Show Posts' : 'Show Reports',
            onPressed: () => setState(() => _showReports = !_showReports),
          ),
        ],
      ),
      body: Column(
        children: [
          // Removed category dropdown
          Expanded(
            child: _showReports
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reports')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: \\${snapshot.error}'),
                        );
                      }
                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(child: Text('No reports found.'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: docs.length,
                        separatorBuilder: (context, i) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final doc = docs[i];
                          final data = doc.data() as Map<String, dynamic>;
                          return FutureBuilder<Map<String, dynamic>?>(
                            future: _fetchReportedContent(data),
                            builder: (context, contentSnapshot) {
                              final content = contentSnapshot.data;
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            data['postType'] == 'question'
                                                ? Icons.forum
                                                : Icons.comment,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            data['postType'] == 'question'
                                                ? 'Question'
                                                : 'Answer',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            data['timestamp'] != null
                                                ? (data['timestamp']
                                                          as Timestamp)
                                                      .toDate()
                                                      .toLocal()
                                                      .toString()
                                                      .substring(0, 16)
                                                : '',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Reason: ${data['reason']}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Reported by: ${data['reportedBy'] ?? 'Anonymous'}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (content != null)
                                        Text(
                                          'Content: ${content['text']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('questions')
                        .orderBy('isPinned', descending: true)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: \\${snapshot.error}'),
                        );
                      }
                      final docs = snapshot.data?.docs ?? [];
                      // Remove category filter logic
                      var posts = docs.toList();
                      if (posts.isEmpty) {
                        return const Center(child: Text('No posts found.'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: posts.length,
                        separatorBuilder: (context, i) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final doc = posts[i];
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildPostCard(doc.id, data);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Removed _buildCategoryDropdown

  Widget _buildPostCard(String postId, Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPostDetail(postId, data),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Removed pinned and flagged icons
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(data['posterUserID'])
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            final userData =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            if (userData != null &&
                                userData['banned'] == true) {
                              return const Text(
                                'User BANNED',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showPostDialog(editPostId: postId, existing: data);
                      } else if (value == 'delete') {
                        _deletePost(postId);
                      } else if (value == 'pin') {
                        _db.pinForumPost(postId, !(data['isPinned'] == true));
                      } else if (value == 'hide') {
                        await FirebaseFirestore.instance
                            .collection('questions')
                            .doc(postId)
                            .update({'hidden': !(data['hidden'] == true)});
                      } else if (value == 'ban') {
                        await _db.banUser(data['posterUserID']);
                        setState(() {});
                      } else if (value == 'reviewed') {
                        await FirebaseFirestore.instance
                            .collection('questions')
                            .doc(postId)
                            .update({'isFlagged': false, 'flagCount': 0});
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(data['isPinned'] == true ? 'Unpin' : 'Pin'),
                      ),
                      PopupMenuItem(
                        value: 'hide',
                        child: Text(data['hidden'] == true ? 'Unhide' : 'Hide'),
                      ),
                      const PopupMenuItem(
                        value: 'ban',
                        child: Text('Ban User'),
                      ),
                      if (data['isFlagged'] == true ||
                          (data['flagCount'] ?? 0) > 0)
                        const PopupMenuItem(
                          value: 'reviewed',
                          child: Text('Mark as Reviewed'),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (data['hidden'] == true)
                const Text(
                  'This post is hidden',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text(data['postContent'] ?? ''),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Upvotes: ${data['upvotes'] ?? 0}'),
                  const SizedBox(width: 12),
                  Text('Downvotes: ${data['downvotes'] ?? 0}'),
                  const Spacer(),
                  // Removed category display
                ],
              ),
              const SizedBox(height: 8),
              _buildReplies(postId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplies(String postId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('questions')
          .doc(postId)
          .collection('replies')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }
        final replies = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: replies.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              color: data['hidden'] == true ? Colors.orange[50] : null,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(data['replyContent'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(data['replierUserID'])
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        if (userData != null && userData['banned'] == true) {
                          return const Text(
                            'User BANNED',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    if (data['hidden'] == true)
                      const Text(
                        'This reply is hidden',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      _showReplyDialog(postId, doc.id, existing: data);
                    } else if (value == 'delete') {
                      await FirebaseFirestore.instance
                          .collection('questions')
                          .doc(postId)
                          .collection('replies')
                          .doc(doc.id)
                          .delete();
                    } else if (value == 'hide') {
                      await FirebaseFirestore.instance
                          .collection('questions')
                          .doc(postId)
                          .collection('replies')
                          .doc(doc.id)
                          .update({'hidden': !(data['hidden'] == true)});
                    } else if (value == 'ban') {
                      await _db.banUser(data['replierUserID']);
                      setState(() {});
                    } else if (value == 'reviewed') {
                      await FirebaseFirestore.instance
                          .collection('questions')
                          .doc(postId)
                          .collection('replies')
                          .doc(doc.id)
                          .update({'isFlagged': false, 'flagCount': 0});
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    PopupMenuItem(
                      value: 'hide',
                      child: Text(data['hidden'] == true ? 'Unhide' : 'Hide'),
                    ),
                    const PopupMenuItem(value: 'ban', child: Text('Ban User')),
                    if (data['isFlagged'] == true ||
                        (data['flagCount'] ?? 0) > 0)
                      const PopupMenuItem(
                        value: 'reviewed',
                        child: Text('Mark as Reviewed'),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showPostDialog({String? editPostId, Map<String, dynamic>? existing}) {
    final titleController = TextEditingController(
      text: existing?['title'] ?? '',
    );
    final contentController = TextEditingController(
      text: existing?['postContent'] ?? '',
    );
    String? selectedCategory = existing?['category'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editPostId == null ? 'Edit Post' : 'Edit Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              _buildCategoryDropdownForDialog(
                selectedCategory,
                (val) => selectedCategory = val,
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
              if (titleController.text.trim().isEmpty ||
                  contentController.text.trim().isEmpty) {
                return;
              }
              if (editPostId != null) {
                await _db.updateForumPost(editPostId, {
                  'title': titleController.text.trim(),
                  'postContent': contentController.text.trim(),
                  'category': selectedCategory ?? '',
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdownForDialog(
    String? selected,
    void Function(String?) onChanged,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('forumCategories')
          .snapshots(),
      builder: (context, snapshot) {
        final categories = <String>[];
        if (snapshot.hasData) {
          categories.addAll(
            snapshot.data!.docs.map((d) => d['name'] as String),
          );
        }
        return DropdownButton<String>(
          value: selected,
          hint: const Text('Category'),
          items: categories
              .map(
                (cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                ),
              )
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }

  void _deletePost(String postId) async {
    await _db.deleteForumPost(postId);
  }

  void _showPostDetail(String postId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          AdminForumPostDetailSheet(postId: postId, postData: data, db: _db),
    );
  }

  void _showCategoryManager() {
    showDialog(
      context: context,
      builder: (context) => CategoryManagerDialog(db: _db),
    );
  }

  void _showReplyDialog(
    String postId,
    String replyId, {
    Map<String, dynamic>? existing,
  }) {
    final controller = TextEditingController(
      text: existing?['replyContent'] ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reply'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reply'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await _db.updateForumReply(postId, replyId, {
                'replyContent': controller.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchReportedContent(
    Map<String, dynamic> data,
  ) async {
    try {
      if (data['postType'] == 'question') {
        // Fetch the question document
        final doc = await FirebaseFirestore.instance
            .collection('questions')
            .doc(data['postId'])
            .get();
        if (doc.exists) {
          final q = doc.data() as Map<String, dynamic>;
          return {'text': q['title'] ?? q['postContent'] ?? '[No content]'};
        }
      } else if (data['postType'] == 'answer') {
        // Fetch the answer document
        final answerDoc = await FirebaseFirestore.instance
            .collection('questions')
            .doc(data['postId'])
            .collection('answers')
            .doc(data['answerId'])
            .get();
        if (answerDoc.exists) {
          final a = answerDoc.data() as Map<String, dynamic>;
          return {'text': a['answer'] ?? '[No content]'};
        }
      }
    } catch (e) {
      // Optionally log error
      return {'text': '[Error loading content]'};
    }
    return {'text': '[Content not found]'};
  }
}

class AdminForumPostDetailSheet extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;
  final DatabaseService db;
  const AdminForumPostDetailSheet({
    required this.postId,
    required this.postData,
    required this.db,
    super.key,
  });

  @override
  State<AdminForumPostDetailSheet> createState() =>
      _AdminForumPostDetailSheetState();
}

class _AdminForumPostDetailSheetState extends State<AdminForumPostDetailSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.postData['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(widget.postData['postContent'] ?? ''),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Upvotes: ${widget.postData['upvotes'] ?? 0}'),
                    const SizedBox(width: 12),
                    Text('Downvotes: ${widget.postData['downvotes'] ?? 0}'),
                    const Spacer(),
                    Text(
                      widget.postData['category'] ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(),
                const Text(
                  'Replies',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('questions')
                      .doc(widget.postId)
                      .collection('replies')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final replies = snapshot.data?.docs ?? [];
                    if (replies.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No replies yet.'),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: replies.length,
                      separatorBuilder: (context, i) => const Divider(),
                      itemBuilder: (context, i) {
                        final reply = replies[i];
                        final replyData = reply.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(replyData['replyContent'] ?? ''),
                          subtitle: Text(replyData['replierEmail'] ?? ''),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditReplyDialog(reply.id, replyData);
                              } else if (value == 'delete') {
                                widget.db.deleteForumReply(
                                  widget.postId,
                                  reply.id,
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditReplyDialog(String replyId, Map<String, dynamic> existing) {
    final controller = TextEditingController(
      text: existing['replyContent'] ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reply'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reply'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await widget.db.updateForumReply(widget.postId, replyId, {
                'replyContent': controller.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class CategoryManagerDialog extends StatefulWidget {
  final DatabaseService db;
  const CategoryManagerDialog({required this.db, super.key});

  @override
  State<CategoryManagerDialog> createState() => _CategoryManagerDialogState();
}

class _CategoryManagerDialogState extends State<CategoryManagerDialog> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Categories'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'New Category'),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('forumCategories')
                .snapshots(),
            builder: (context, snapshot) {
              final categories = snapshot.data?.docs ?? [];
              return ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  return ListTile(
                    title: Text(cat['name'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await widget.db.deleteForumCategory(cat.id);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_categoryController.text.trim().isEmpty) return;
            await widget.db.createForumCategory(
              name: _categoryController.text.trim(),
            );
            _categoryController.clear();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
