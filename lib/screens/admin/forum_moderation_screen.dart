import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strathapp/services/database_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Moderation'),
        actions: [
          IconButton(
            icon: Icon(_showFlagged ? Icons.flag : Icons.outlined_flag),
            tooltip: _showFlagged ? 'Show All' : 'Show Flagged',
            onPressed: () => setState(() => _showFlagged = !_showFlagged),
          ),
          IconButton(
            icon: Icon(_showPinned ? Icons.push_pin : Icons.push_pin_outlined),
            tooltip: _showPinned ? 'Show All' : 'Show Pinned',
            onPressed: () => setState(() => _showPinned = !_showPinned),
          ),
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Manage Categories',
            onPressed: _showCategoryManager,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(children: [_buildCategoryDropdown()]),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('forumPosts')
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
                  final category = (data['category'] ?? '').toString();
                  final matchesCategory =
                      _selectedCategory == null ||
                      _selectedCategory == '' ||
                      category == _selectedCategory;
                  final matchesFlagged =
                      !_showFlagged ||
                      (data['isFlagged'] == true ||
                          (data['flagCount'] ?? 0) > 0);
                  final matchesPinned =
                      !_showPinned || (data['isPinned'] == true);
                  return matchesCategory && matchesFlagged && matchesPinned;
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
                  if (data['isFlagged'] == true || (data['flagCount'] ?? 0) > 0)
                    const Icon(Icons.flag, color: Colors.red, size: 18),
                  Expanded(
                    child: Text(
                      data['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showPostDialog(editPostId: postId, existing: data);
                      } else if (value == 'delete') {
                        _deletePost(postId);
                      } else if (value == 'pin') {
                        _db.pinForumPost(postId, !(data['isPinned'] == true));
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
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(data['postContent'] ?? ''),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Upvotes: ${data['upvotes'] ?? 0}'),
                  const SizedBox(width: 12),
                  Text('Downvotes: ${data['downvotes'] ?? 0}'),
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
                      .collection('forumPosts')
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
