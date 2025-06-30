import 'package:cloud_firestore/cloud_firestore.dart';

// Note: This service provides the functions to interact with Firestore based on your schema.
// You will need to call these methods from your UI widgets. For example, when an admin
// fills out a form to create a new event, you would call `DatabaseService().createCampusEvent(...)`.

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- User/Student/Admin Management ---
  // The 'users' collection is typically managed in AuthService during signup.
  // These functions handle the related 'students' and 'admins' profiles.

  /// Creates a student-specific profile document.
  Future<void> createStudentProfile(
    String uid, {
    String? profilePictureURL,
    String? onboardingChecklistID,
  }) async {
    final studentsCollection = _firestore.collection('students');
    await studentsCollection.doc(uid).set({
      'userID': uid,
      'profilePictureURL': profilePictureURL,
      'onboardingChecklistID': onboardingChecklistID,
      'notifications': [],
    });
  }

  /// Creates an admin-specific profile document.
  /// Note: This should be called from a secure context (e.g., a Cloud Function or manually).
  Future<void> createAdminProfile(
    String uid, {
    required String department,
    String? profilePictureURL,
  }) async {
    final adminsCollection = _firestore.collection('admins');
    await adminsCollection.doc(uid).set({
      'userID': uid,
      'department': department,
      'profilePictureURL': profilePictureURL,
    });
  }

  /// Updates a user's document in the 'users' collection.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  /// Updates an admin's profile data.
  Future<void> updateAdminProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('admins').doc(uid).update(data);
  }

  // --- Campus Events ---
  Future<DocumentReference> createCampusEvent({
    required String eventName,
    required String description,
    required DateTime eventDate,
    required String eventTime,
    required String locationID,
    required String organizer,
    required String createdByAdminID,
  }) async {
    final eventsCollection = _firestore.collection('campusEvents');
    return await eventsCollection.add({
      'eventName': eventName,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventTime': eventTime,
      'locationID': locationID,
      'organizer': organizer,
      'createdByAdminID': createdByAdminID,
    });
  }

  // --- Campus Locations ---
  Future<DocumentReference> createCampusLocation({
    required String locationName,
    required String type,
    required GeoPoint coordinates,
    String? description,
    List<String>? imageURLs,
  }) async {
    final locationsCollection = _firestore.collection('campusLocations');
    return await locationsCollection.add({
      'locationName': locationName,
      'type': type,
      'coordinates': coordinates,
      'description': description,
      'imageURLs': imageURLs ?? [],
    });
  }

  // --- Forum Posts ---
  Future<DocumentReference> createForumPost({
    required String posterUserID,
    required String title,
    required String postContent,
  }) async {
    final forumCollection = _firestore.collection('forumPosts');
    return await forumCollection.add({
      'posterUserID': posterUserID,
      'timestamp': FieldValue.serverTimestamp(),
      'title': title,
      'postContent': postContent,
      'replies': [],
    });
  }

  // --- Onboarding Checklists ---
  Future<void> createOnboardingChecklist({
    required String studentID,
    required String templateName,
    required List<Map<String, dynamic>> tasks,
  }) async {
    final checklistCollection = _firestore.collection('onboardingChecklists');
    // Example task format: {'taskID': 'task1', 'description': 'Visit library', 'status': 'pending'}
    await checklistCollection.doc(studentID).set({
      'studentID': studentID,
      'templateName': templateName,
      'tasks': tasks,
    });
  }

  // --- Content Reports ---
  Future<DocumentReference> createContentReport({
    required String reportedItemID,
    required String reporterUserID,
    required String reason,
  }) async {
    final reportsCollection = _firestore.collection('contentReports');
    return await reportsCollection.add({
      'reportedItemID': reportedItemID,
      'reporterUserID': reporterUserID,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
      'reviewedByAdminID': null,
    });
  }

  // --- Support Tickets ---
  Future<DocumentReference> createSupportTicket({
    required String requesterUserID,
    required String subject,
    required String message,
  }) async {
    final ticketsCollection = _firestore.collection('supportTickets');
    return await ticketsCollection.add({
      'requesterUserID': requesterUserID,
      'subject': subject,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'open',
      'adminResponse': null,
      'respondedByAdminID': null,
    });
  }
}
