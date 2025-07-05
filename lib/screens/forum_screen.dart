import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strathapp/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showPinned = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forum',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_showPinned ? Icons.push_pin : Icons.push_pin_outlined),
            tooltip: _showPinned ? 'Show All' : 'Show Pinned',
            onPressed: () => setState(() => _showPinned = !_showPinned),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ask a Question',
            onPressed: () => _showPostDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search posts...',
                    ),
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim().toLowerCase()),
                  ),
                ),
                const SizedBox(width: 8),
                _buildCategoryDropdown(),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  return Center(child: Text('Error: \\${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                var posts = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final content = (data['postContent'] ?? '')
                      .toString()
                      .toLowerCase();
                  final category = (data['category'] ?? '').toString();
                  final matchesSearch =
                      _searchQuery.isEmpty ||
                      title.contains(_searchQuery) ||
                      content.contains(_searchQuery);
                  final matchesCategory =
                      _selectedCategory == null ||
                      _selectedCategory == '' ||
                      category == _selectedCategory;
                  final matchesPinned =
                      !_showPinned || (data['isPinned'] == true);
                  return matchesSearch && matchesCategory && matchesPinned;
                }).toList();
                if (posts.isEmpty) {
                  return const Center(child: Text('No posts found.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: posts.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 10),
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

  Widget _buildCategoryDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('forumCategories')
          .snapshots(),
      builder: (context, snapshot) {
        final categories = <String>[''];
        if (snapshot.hasData) {
          categories.addAll(
            snapshot.data!.docs.map((d) => d['name'] as String),
          );
        }
        return DropdownButton<String>(
          value: _selectedCategory ?? '',
          hint: const Text('Category'),
          items: categories
              .map(
                (cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat.isEmpty ? 'All' : cat),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        );
      },
    );
  }

  Widget _buildPostCard(String postId, Map<String, dynamic> data) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user != null && user.uid == data['posterUserID'];
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
                  if (data['isPinned'] == true)
                    const Icon(Icons.push_pin, color: Colors.orange, size: 18),
                  Expanded(
                    child: Text(
                      data['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isOwner)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showPostDialog(editPostId: postId, existing: data);
                        } else if (value == 'delete') {
                          _deletePost(postId);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  IconButton(
                    icon: const Icon(Icons.flag, color: Colors.red),
                    tooltip: 'Report',
                    onPressed: () => _showReportDialog(postId: postId),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(data['postContent'] ?? ''),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up),
                    onPressed: () => _db.upvoteForumPost(postId),
                  ),
                  Text('${data['upvotes'] ?? 0}'),
                  IconButton(
                    icon: const Icon(Icons.thumb_down),
                    onPressed: () => _db.downvoteForumPost(postId),
                  ),
                  Text('${data['downvotes'] ?? 0}'),
                  const Spacer(),
                  Text(
                    data['category'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostDialog({String? editPostId, Map<String, dynamic>? existing}) {
    final user = FirebaseAuth.instance.currentUser;
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
        title: Text(editPostId == null ? 'Ask a Question' : 'Edit Post'),
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
              if (editPostId == null) {
                await _db.createForumPost(
                  posterUserID: user!.uid,
                  posterEmail: user.email ?? '',
                  title: titleController.text.trim(),
                  postContent: contentController.text.trim(),
                  category: selectedCategory ?? '',
                );
              } else {
                await _db.updateForumPost(editPostId, {
                  'title': titleController.text.trim(),
                  'postContent': contentController.text.trim(),
                  'category': selectedCategory ?? '',
                });
              }
              Navigator.pop(context);
            },
            child: Text(editPostId == null ? 'Post' : 'Update'),
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
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }

  void _deletePost(String postId) async {
    await _db.deleteForumPost(postId);
  }

  void _showReportDialog({required String postId, String? replyId}) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (reasonController.text.trim().isEmpty || user == null) return;
              if (replyId == null) {
                await _db.reportForumPost(
                  postId: postId,
                  reporterUserID: user.uid,
                  reason: reasonController.text.trim(),
                );
              } else {
                await _db.reportForumReply(
                  postId: postId,
                  replyId: replyId,
                  reporterUserID: user.uid,
                  reason: reasonController.text.trim(),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showPostDetail(String postId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          ForumPostDetailSheet(postId: postId, postData: data, db: _db),
    );
  }
}

class ForumPostDetailSheet extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;
  final DatabaseService db;
  const ForumPostDetailSheet({
    required this.postId,
    required this.postData,
    required this.db,
    super.key,
  });

  @override
  State<ForumPostDetailSheet> createState() => _ForumPostDetailSheetState();
}

class _ForumPostDetailSheetState extends State<ForumPostDetailSheet> {
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
                    IconButton(
                      icon: const Icon(Icons.thumb_up),
                      onPressed: () => widget.db.upvoteForumPost(widget.postId),
                    ),
                    Text('${widget.postData['upvotes'] ?? 0}'),
                    IconButton(
                      icon: const Icon(Icons.thumb_down),
                      onPressed: () =>
                          widget.db.downvoteForumPost(widget.postId),
                    ),
                    Text('${widget.postData['downvotes'] ?? 0}'),
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
                        final isOwner =
                            user != null &&
                            user.uid == replyData['replierUserID'];
                        return ListTile(
                          title: Text(replyData['replyContent'] ?? ''),
                          subtitle: Text(replyData['replierEmail'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up),
                                onPressed: () => widget.db.upvoteForumReply(
                                  widget.postId,
                                  reply.id,
                                ),
                              ),
                              Text('${replyData['upvotes'] ?? 0}'),
                              IconButton(
                                icon: const Icon(Icons.thumb_down),
                                onPressed: () => widget.db.downvoteForumReply(
                                  widget.postId,
                                  reply.id,
                                ),
                              ),
                              Text('${replyData['downvotes'] ?? 0}'),
                              IconButton(
                                icon: const Icon(Icons.flag, color: Colors.red),
                                tooltip: 'Report',
                                onPressed: () =>
                                    _showReportDialog(replyId: reply.id),
                              ),
                              if (isOwner)
                                PopupMenuButton<String>(
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
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        decoration: const InputDecoration(
                          hintText: 'Write a reply...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (_replyController.text.trim().isEmpty ||
                            user == null) {
                          return;
                        }
                        await widget.db.addForumReply(
                          postId: widget.postId,
                          replierUserID: user.uid,
                          replierEmail: user.email ?? '',
                          replyContent: _replyController.text.trim(),
                        );
                        _replyController.clear();
                      },
                    ),
                  ],
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

  void _showReportDialog({required String replyId}) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Reply'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (reasonController.text.trim().isEmpty || user == null) return;
              await widget.db.reportForumReply(
                postId: widget.postId,
                replyId: replyId,
                reporterUserID: user.uid,
                reason: reasonController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
