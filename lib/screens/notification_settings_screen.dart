import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _academicNotifications = true;
  bool _eventNotifications = true;
  bool _libraryNotifications = true;
  bool _maintenanceNotifications = true;
  bool _securityNotifications = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _academicNotifications = prefs.getBool('academic_notifications') ?? true;
      _eventNotifications = prefs.getBool('event_notifications') ?? true;
      _libraryNotifications = prefs.getBool('library_notifications') ?? true;
      _maintenanceNotifications =
          prefs.getBool('maintenance_notifications') ?? true;
      _securityNotifications = prefs.getBool('security_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? false;
      _smsNotifications = prefs.getBool('sms_notifications') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('academic_notifications', _academicNotifications);
    await prefs.setBool('event_notifications', _eventNotifications);
    await prefs.setBool('library_notifications', _libraryNotifications);
    await prefs.setBool('maintenance_notifications', _maintenanceNotifications);
    await prefs.setBool('security_notifications', _securityNotifications);
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('email_notifications', _emailNotifications);
    await prefs.setBool('sms_notifications', _smsNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A2B6B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2B6B),
              ),
            ),
            const SizedBox(height: 16),
            _buildNotificationTypeCard(
              'Academic Notifications',
              'Assignment due dates, exam schedules, grade updates',
              Icons.school,
              _academicNotifications,
              (value) {
                setState(() {
                  _academicNotifications = value;
                });
                _saveSettings();
              },
            ),
            _buildNotificationTypeCard(
              'Event Notifications',
              'Campus events, workshops, student organization meetings',
              Icons.event,
              _eventNotifications,
              (value) {
                setState(() {
                  _eventNotifications = value;
                });
                _saveSettings();
              },
            ),
            _buildNotificationTypeCard(
              'Library Notifications',
              'Book due dates, reservation confirmations, library updates',
              Icons.library_books,
              _libraryNotifications,
              (value) {
                setState(() {
                  _libraryNotifications = value;
                });
                _saveSettings();
              },
            ),
            _buildNotificationTypeCard(
              'Maintenance Notifications',
              'System maintenance, portal updates, IT announcements',
              Icons.build,
              _maintenanceNotifications,
              (value) {
                setState(() {
                  _maintenanceNotifications = value;
                });
                _saveSettings();
              },
            ),
            _buildNotificationTypeCard(
              'Security Notifications',
              'Emergency alerts, safety updates, security incidents',
              Icons.security,
              _securityNotifications,
              (value) {
                setState(() {
                  _securityNotifications = value;
                });
                _saveSettings();
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Delivery Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2B6B),
              ),
            ),
            const SizedBox(height: 16),
            _buildDeliveryMethodCard(
              'Push Notifications',
              'Receive notifications on your device',
              Icons.notifications,
              _pushNotifications,
              (value) {
                setState(() {
                  _pushNotifications = value;
                });
                _saveSettings();
              },
            ),
            _buildDeliveryMethodCard(
              'Email Notifications',
              'Receive notifications via email',
              Icons.email,
              _emailNotifications,
              (value) {
                setState(() {
                  _emailNotifications = value;
                });
                _saveSettings();
              },
            ),
            _buildDeliveryMethodCard(
              'SMS Notifications',
              'Receive notifications via text message',
              Icons.sms,
              _smsNotifications,
              (value) {
                setState(() {
                  _smsNotifications = value;
                });
                _saveSettings();
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Notification Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2B6B),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A2B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Color(0xFF0A2B6B),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Quiet Hours',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: const Text(
                  '10:00 PM - 8:00 AM\nNotifications will be silenced during these hours',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to quiet hours settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quiet hours settings coming soon!'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Test notification
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test notification sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2B6B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send Test Notification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypeCard(
    String title,
    String description,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0A2B6B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0A2B6B), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF0A2B6B),
        ),
      ),
    );
  }

  Widget _buildDeliveryMethodCard(
    String title,
    String description,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0A2B6B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0A2B6B), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF0A2B6B),
        ),
      ),
    );
  }
}
