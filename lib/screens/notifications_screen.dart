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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A2B6B),
        elevation: 0,
        actions: [
          if (_sampleNotifications.any((n) => !n['isRead']))
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
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0A2B6B)),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2B6B),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _sampleNotifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sampleNotifications.length,
              itemBuilder: (context, index) {
                final notification = _sampleNotifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final priority = notification['priority'] as String;
    final type = notification['type'] as String;
    final timestamp = notification['timestamp'] as DateTime;

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${notification['title']} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _sampleNotifications.add(notification);
                });
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isRead ? 1 : 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead ? Colors.transparent : _getPriorityColor(priority),
              width: isRead ? 0 : 2,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getPriorityColor(priority).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getNotificationIcon(type),
                color: _getPriorityColor(priority),
                size: 24,
              ),
            ),
            title: Text(
              notification['title'],
              style: TextStyle(
                fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                fontSize: 16,
                color: isRead ? Colors.grey[700] : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeAgo(timestamp),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const Spacer(),
                    if (!isRead)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          priority.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'mark_read':
                    _markAsRead(notification['id']);
                    break;
                  case 'delete':
                    _deleteNotification(notification['id']);
                    break;
                }
              },
              itemBuilder: (context) => [
                if (!isRead)
                  const PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(Icons.done),
                        SizedBox(width: 8),
                        Text('Mark as read'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              if (!isRead) {
                _markAsRead(notification['id']);
              }
              // Here you could navigate to a detailed view or perform an action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening ${notification['title']}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
