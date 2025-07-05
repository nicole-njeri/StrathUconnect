import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'notification_settings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  // Real notifications from Firestore
  final List<Map<String, dynamic>> _notifications = [];

  // Sample notifications fallback (for demo/testing)
  final List<Map<String, dynamic>> _sampleNotifications = [
    {
      'id': '1',
      'title': 'Event Reminder',
      'message': 'Don\'t forget the campus event tomorrow!',
      'type': 'event',
      'priority': 'high',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Library Notice',
      'message': 'Library will close early today.',
      'type': 'library',
      'priority': 'medium',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
    },
    {
      'id': '3',
      'title': 'Maintenance',
      'message': 'Water outage in Block C.',
      'type': 'maintenance',
      'priority': 'low',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      // Get current user ID
      final user = _authService.currentUser;
      if (user != null) {
        _currentUserId = user.uid;
      }

      // Load notifications from Firestore
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load notifications.";
          _isLoading = false;
        });
      }
    }
  }

  void _markAsRead(String notificationId) async {
    try {
      if (_currentUserId != null) {
        await _notificationService.markAsRead(notificationId);
      } else {
        // Fallback to local state for demo
        setState(() {
          final notification = _sampleNotifications.firstWhere(
            (n) => n['id'] == notificationId,
          );
          notification['isRead'] = true;
        });
      }
    } catch (e) {
      // Handle error
      debugPrint('Error marking notification as read: $e');
    }
  }

  void _markAllAsRead() async {
    try {
      if (_currentUserId != null) {
        await _notificationService.markAllAsRead(_currentUserId!);
      } else {
        // Fallback to local state for demo
        setState(() {
          for (var notification in _sampleNotifications) {
            notification['isRead'] = true;
          }
        });
      }
    } catch (e) {
      // Handle error
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  void _deleteNotification(String notificationId) async {
    try {
      if (_currentUserId != null) {
        await _notificationService.deleteNotification(notificationId);
      } else {
        // Fallback to local state for demo
        setState(() {
          _sampleNotifications.removeWhere((n) => n['id'] == notificationId);
        });
      }
    } catch (e) {
      // Handle error
      debugPrint('Error deleting notification: $e');
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'academic':
        return Icons.school;
      case 'event':
        return Icons.event;
      case 'library':
        return Icons.library_books;
      case 'maintenance':
        return Icons.build;
      case 'security':
        return Icons.security;
      default:
        return Icons.notifications;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _sampleNotifications; // Use sample for demo
    return Scaffold(
      backgroundColor: const Color(0xFFF6EEDD),
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Notifications',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFF0A2B6B),
        elevation: 0,
        actions: [
          if (notifications.any((n) => !n['isRead']))
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Notification settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, i) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final n = notifications[i];
                final priorityColor = n['priority'] == 'high'
                    ? Colors.red
                    : n['priority'] == 'low'
                    ? Colors.green
                    : Colors.orange;
                return Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: priorityColor.withOpacity(0.7),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getNotificationIcon(n['type']),
                              color: priorityColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n['title'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Color(0xFF0A2B6B),
                                        ),
                                      ),
                                    ),
                                    if (n['priority'] == 'high' ||
                                        n['priority'] == 'low')
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: priorityColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: priorityColor,
                                          ),
                                        ),
                                        child: Text(
                                          n['priority']
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: priorityColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n['message'],
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getTimeAgo(n['timestamp']),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteNotification(n['id']);
                              } else if (value == 'mark_read') {
                                _markAsRead(n['id']);
                              }
                            },
                            itemBuilder: (context) => [
                              if (!n['isRead'])
                                const PopupMenuItem(
                                  value: 'mark_read',
                                  child: Text('Mark as read'),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            icon: const Icon(
                              Icons.more_vert,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
