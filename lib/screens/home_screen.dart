import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/home_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  DocumentSnapshot? _userSnapshot;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;

  final List<Map<String, dynamic>> cards = [
    {'icon': Icons.place, 'title': 'Find a Place'},
    {'icon': Icons.chat_bubble_outline, 'title': 'Ask a Question'},
    {'icon': Icons.check_box, 'title': 'My Checklist'},
    {'icon': Icons.campaign_outlined, 'title': 'Campus Updates'},
  ];

  @override
  void initState() {
    super.initState();
    print("[HomeScreen] initState: Kicking off user data load.");
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print("[HomeScreen] _loadUserData: Attempting to fetch user details...");
    try {
      final snapshot = await _authService.getUserDetails();
      print("[HomeScreen] _loadUserData: Successfully fetched data. User exists: ${snapshot.exists}");
      if (mounted) {
        setState(() {
          _userSnapshot = snapshot;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("[HomeScreen] _loadUserData: An error occurred: $e");
      if (mounted) {
        setState(() {
          _error = "Failed to load user data.";
          _isLoading = false;
        });
      }
    }
  }

  String get _userName {
    if (_userSnapshot != null && _userSnapshot!.exists) {
      final data = _userSnapshot!.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('fullName')) {
        return data['fullName'].split(' ')[0]; // Just get first name
      }
    }
    return 'User'; // Default name
  }

  @override
  Widget build(BuildContext context) {
    print("[HomeScreen] build: Running build method. isLoading: $_isLoading, error: $_error");
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA), // Light background
      appBar: AppBar(
        title: Text('StrathUConnect'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              // The StreamBuilder in main.dart will handle navigation
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_error!),
                  ))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Hi $_userName 👋',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ListView.builder(
                            itemCount: cards.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: HomeCard(
                                  icon: cards[index]['icon'],
                                  title: cards[index]['title'],
                                  onTap: () {},
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Handle navigation or state change for other tabs
        },
        selectedItemColor: Color(0xFFB50127), // Red
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
