import 'package:flutter/material.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: 'Dashboard'),
    Tab(text: 'Users'),
    Tab(text: 'Locations'),
    Tab(text: 'Events'),
    Tab(text: 'Forum'),
    Tab(text: 'Checklists'),
    Tab(text: 'Notifications'),
    Tab(text: 'Reports'),
    Tab(text: 'Support'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  // Placeholder for admin check
  bool get isAdmin => true; // TODO: Replace with real admin check

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Access denied. Admins only.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DashboardTab(),
          _UsersTab(),
          _LocationsTab(),
          _EventsTab(),
          _ForumTab(),
          _ChecklistsTab(),
          _NotificationsTab(),
          _ReportsTab(),
          _SupportTab(),
        ],
      ),
    );
  }
}

// --- Placeholder Widgets for Each Tab ---
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Overview dashboard and metrics.'));
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Restrict/Ban users.'));
}

class _LocationsTab extends StatelessWidget {
  const _LocationsTab();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Manage campus locations.'));
}

class _EventsTab extends StatelessWidget {
  const _EventsTab();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Manage campus events.'));
}

class _ForumTab extends StatelessWidget {
  const _ForumTab();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Moderate forum content.'));
}

class _ChecklistsTab extends StatelessWidget {
  const _ChecklistsTab();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Manage onboarding checklists.'));
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Send notifications.'));
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Generate/view reports.'));
}

class _SupportTab extends StatelessWidget {
  const _SupportTab();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Manage support requests and feedback.'));
}
