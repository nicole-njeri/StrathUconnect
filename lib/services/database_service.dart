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

  /// Ban a user by setting banned: true in the users collection
  Future<void> banUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({'banned': true});
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

  // --- Forum Posts (Unified Model) ---
  Future<DocumentReference> createForumPost({
    required String posterUserID,
    required String posterEmail,
    required String title,
    required String postContent,
    required String category,
  }) async {
    final forumCollection = _firestore.collection('questions');
    return await forumCollection.add({
      'posterUserID': posterUserID,
      'posterEmail': posterEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'title': title,
      'postContent': postContent,
      'category': category,
      'upvotes': 0,
      'downvotes': 0,
      'isPinned': false,
      'isFlagged': false,
      'flagCount': 0,
    });
  }

  Future<void> updateForumPost(String postId, Map<String, dynamic> data) async {
    await _firestore.collection('questions').doc(postId).update(data);
  }

  Future<void> deleteForumPost(String postId) async {
    await _firestore.collection('questions').doc(postId).delete();
  }

  Future<void> upvoteForumPost(String postId) async {
    await _firestore.collection('questions').doc(postId).update({
      'upvotes': FieldValue.increment(1),
    });
  }

  Future<void> downvoteForumPost(String postId) async {
    await _firestore.collection('questions').doc(postId).update({
      'downvotes': FieldValue.increment(1),
    });
  }

  Future<DocumentReference> addForumReply({
    required String postId,
    required String replierUserID,
    required String replierEmail,
    required String replyContent,
  }) async {
    final repliesCollection = _firestore
        .collection('questions')
        .doc(postId)
        .collection('replies');
    return await repliesCollection.add({
      'replierUserID': replierUserID,
      'replierEmail': replierEmail,
      'replyContent': replyContent,
      'timestamp': FieldValue.serverTimestamp(),
      'upvotes': 0,
      'downvotes': 0,
      'isFlagged': false,
      'flagCount': 0,
    });
  }

  Future<void> updateForumReply(
    String postId,
    String replyId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('questions')
        .doc(postId)
        .collection('replies')
        .doc(replyId)
        .update(data);
  }

  Future<void> deleteForumReply(String postId, String replyId) async {
    await _firestore
        .collection('questions')
        .doc(postId)
        .collection('replies')
        .doc(replyId)
        .delete();
  }

  Future<void> upvoteForumReply(String postId, String replyId) async {
    await _firestore
        .collection('questions')
        .doc(postId)
        .collection('replies')
        .doc(replyId)
        .update({'upvotes': FieldValue.increment(1)});
  }

  Future<void> downvoteForumReply(String postId, String replyId) async {
    await _firestore
        .collection('questions')
        .doc(postId)
        .collection('replies')
        .doc(replyId)
        .update({'downvotes': FieldValue.increment(1)});
  }

  // --- Forum Reports ---
  Future<DocumentReference> reportForumPost({
    required String postId,
    required String reporterUserID,
    required String reason,
  }) async {
    final reportsCollection = _firestore
        .collection('questions')
        .doc(postId)
        .collection('reports');
    return await reportsCollection.add({
      'reporterUserID': reporterUserID,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
      'resolved': false,
    });
  }

  Future<DocumentReference> reportForumReply({
    required String postId,
    required String replyId,
    required String reporterUserID,
    required String reason,
  }) async {
    final reportsCollection = _firestore
        .collection('questions')
        .doc(postId)
        .collection('replies')
        .doc(replyId)
        .collection('reports');
    return await reportsCollection.add({
      'reporterUserID': reporterUserID,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
      'resolved': false,
    });
  }

  // --- Pin/Unpin Post ---
  Future<void> pinForumPost(String postId, bool isPinned) async {
    await _firestore.collection('questions').doc(postId).update({
      'isPinned': isPinned,
    });
  }

  // --- Category Management ---
  Future<DocumentReference> createForumCategory({required String name}) async {
    final categoriesCollection = _firestore.collection('forumCategories');
    return await categoriesCollection.add({'name': name});
  }

  Future<void> deleteForumCategory(String categoryId) async {
    await _firestore.collection('forumCategories').doc(categoryId).delete();
  }

  // --- Onboarding Checklists (Enhanced) ---
  Future<void> createOnboardingChecklist({
    required String studentID,
    required String templateName,
    required List<Map<String, dynamic>> tasks,
  }) async {
    final checklistCollection = _firestore.collection('onboardingChecklists');
    await checklistCollection.doc(studentID).set({
      'studentID': studentID,
      'templateName': templateName,
      'tasks': tasks,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'completedTasks': 0,
      'totalTasks': tasks.length,
    });
  }

  Future<void> updateOnboardingChecklist(
    String studentID,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('onboardingChecklists').doc(studentID).update({
      ...data,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTaskStatus(
    String studentID,
    int taskIndex,
    bool isCompleted,
  ) async {
    final doc = await _firestore
        .collection('onboardingChecklists')
        .doc(studentID)
        .get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        final tasks = List<Map<String, dynamic>>.from(data['tasks'] ?? []);
        if (taskIndex < tasks.length) {
          tasks[taskIndex]['isCompleted'] = isCompleted;
          final completedCount = tasks
              .where((task) => task['isCompleted'] == true)
              .length;
          await _firestore
              .collection('onboardingChecklists')
              .doc(studentID)
              .update({
                'tasks': tasks,
                'completedTasks': completedCount,
                'lastUpdated': FieldValue.serverTimestamp(),
              });
        }
      }
    }
  }

  Future<Map<String, dynamic>?> getOnboardingChecklist(String studentID) async {
    final doc = await _firestore
        .collection('onboardingChecklists')
        .doc(studentID)
        .get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  // --- Checklist Templates (for admins) ---
  Future<DocumentReference> createChecklistTemplate({
    required String templateName,
    required String description,
    required List<Map<String, dynamic>> tasks,
  }) async {
    final templatesCollection = _firestore.collection('checklistTemplates');
    return await templatesCollection.add({
      'templateName': templateName,
      'description': description,
      'tasks': tasks,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  Future<void> updateChecklistTemplate(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('checklistTemplates').doc(templateId).update({
      ...data,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteChecklistTemplate(String templateId) async {
    await _firestore.collection('checklistTemplates').doc(templateId).delete();
  }

  Future<List<Map<String, dynamic>>> getAllChecklistTemplates() async {
    final snapshot = await _firestore.collection('checklistTemplates').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> assignChecklistToStudent(
    String studentID,
    String templateId,
  ) async {
    final templateDoc = await _firestore
        .collection('checklistTemplates')
        .doc(templateId)
        .get();
    if (templateDoc.exists) {
      final templateData = templateDoc.data() as Map<String, dynamic>;
      final tasks = List<Map<String, dynamic>>.from(
        templateData['tasks'] ?? [],
      );

      // Initialize all tasks as not completed
      for (var task in tasks) {
        task['isCompleted'] = false;
      }

      await createOnboardingChecklist(
        studentID: studentID,
        templateName: templateData['templateName'] ?? '',
        tasks: tasks,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAllStudentChecklists() async {
    final snapshot = await _firestore.collection('onboardingChecklists').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
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

  // --- Support and Feedback ---
  Future<void> createSupportTicket({
    required String userId,
    required String userEmail,
    required String subject,
    required String description,
    required String category,
    String? priority,
  }) async {
    await _firestore.collection('supportTickets').add({
      'userId': userId,
      'userEmail': userEmail,
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority ?? 'medium',
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'assignedTo': null,
      'responses': [],
    });
  }

  Future<List<Map<String, dynamic>>> getSupportTickets({String? status}) async {
    Query query = _firestore
        .collection('supportTickets')
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    await _firestore.collection('supportTickets').doc(ticketId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> assignTicket(String ticketId, String adminId) async {
    await _firestore.collection('supportTickets').doc(ticketId).update({
      'assignedTo': adminId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addTicketResponse(
    String ticketId, {
    required String responderId,
    required String responderName,
    required String message,
    bool isAdmin = false,
  }) async {
    final ticketRef = _firestore.collection('supportTickets').doc(ticketId);

    await ticketRef.update({
      'responses': FieldValue.arrayUnion([
        {
          'responderId': responderId,
          'responderName': responderName,
          'message': message,
          'isAdmin': isAdmin,
          'timestamp': FieldValue.serverTimestamp(),
        },
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserTickets(String userId) async {
    final snapshot = await _firestore
        .collection('supportTickets')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // --- Feedback Management ---
  Future<void> submitFeedback({
    required String userId,
    required String userEmail,
    required String feedbackType,
    required String message,
    int? rating,
    String? category,
  }) async {
    await _firestore.collection('feedback').add({
      'userId': userId,
      'userEmail': userEmail,
      'feedbackType':
          feedbackType, // 'general', 'feature_request', 'bug_report', 'faq_rating'
      'message': message,
      'rating': rating,
      'category': category,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'reviewedBy': null,
      'reviewedAt': null,
      'adminResponse': null,
    });
  }

  Future<List<Map<String, dynamic>>> getFeedback({
    String? status,
    String? type,
  }) async {
    Query query = _firestore
        .collection('feedback')
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    if (type != null) {
      query = query.where('feedbackType', isEqualTo: type);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<void> updateFeedbackStatus(
    String feedbackId,
    String status, {
    String? adminResponse,
  }) async {
    final updateData = <String, dynamic>{
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
    };

    if (adminResponse != null) {
      updateData['adminResponse'] = adminResponse;
    }

    await _firestore.collection('feedback').doc(feedbackId).update(updateData);
  }

  // --- FAQ Management ---
  Future<void> createFAQ({
    required String question,
    required String answer,
    required String category,
    bool isActive = true,
  }) async {
    await _firestore.collection('faqs').add({
      'question': question,
      'answer': answer,
      'category': category,
      'isActive': isActive,
      'helpfulCount': 0,
      'notHelpfulCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getFAQs({String? category}) async {
    Query query = _firestore
        .collection('faqs')
        .where('isActive', isEqualTo: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<void> updateFAQ(
    String faqId, {
    String? question,
    String? answer,
    String? category,
    bool? isActive,
  }) async {
    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (question != null) updateData['question'] = question;
    if (answer != null) updateData['answer'] = answer;
    if (category != null) updateData['category'] = category;
    if (isActive != null) updateData['isActive'] = isActive;

    await _firestore.collection('faqs').doc(faqId).update(updateData);
  }

  Future<void> deleteFAQ(String faqId) async {
    await _firestore.collection('faqs').doc(faqId).delete();
  }

  Future<void> rateFAQ(String faqId, bool isHelpful) async {
    final faqRef = _firestore.collection('faqs').doc(faqId);

    if (isHelpful) {
      await faqRef.update({'helpfulCount': FieldValue.increment(1)});
    } else {
      await faqRef.update({'notHelpfulCount': FieldValue.increment(1)});
    }
  }

  // --- Support Analytics ---
  Future<Map<String, dynamic>> getSupportAnalytics() async {
    final ticketsSnapshot = await _firestore.collection('supportTickets').get();
    final feedbackSnapshot = await _firestore.collection('feedback').get();
    final faqsSnapshot = await _firestore.collection('faqs').get();

    int openTickets = 0;
    int resolvedTickets = 0;
    int pendingFeedback = 0;
    int reviewedFeedback = 0;

    for (var doc in ticketsSnapshot.docs) {
      final data = doc.data();
      if (data['status'] == 'open') {
        openTickets++;
      } else if (data['status'] == 'resolved') {
        resolvedTickets++;
      }
    }

    for (var doc in feedbackSnapshot.docs) {
      final data = doc.data();
      if (data['status'] == 'pending') {
        pendingFeedback++;
      } else {
        reviewedFeedback++;
      }
    }

    return {
      'totalTickets': ticketsSnapshot.docs.length,
      'openTickets': openTickets,
      'resolvedTickets': resolvedTickets,
      'totalFeedback': feedbackSnapshot.docs.length,
      'pendingFeedback': pendingFeedback,
      'reviewedFeedback': reviewedFeedback,
      'totalFAQs': faqsSnapshot.docs.length,
      'activeFAQs': faqsSnapshot.docs
          .where((doc) => doc.data()['isActive'] == true)
          .length,
    };
  }

  // --- Dummy Support Data ---
  Future<void> generateDummySupportData() async {
    await _generateDummyTickets();
    await _generateDummyFeedback();
    await _generateDummyFAQs();
  }

  Future<void> _generateDummyTickets() async {
    final batch = _firestore.batch();
    final tickets = [
      {
        'userId': 'user_1',
        'userEmail': 'john.doe@strathmore.edu',
        'subject': 'Cannot access forum',
        'description':
            'I\'m unable to post in the forum. Getting an error message.',
        'category': 'Technical Issue',
        'priority': 'high',
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'assignedTo': null,
        'responses': [],
      },
      {
        'userId': 'user_2',
        'userEmail': 'jane.smith@strathmore.edu',
        'subject': 'Event registration problem',
        'description':
            'I tried to register for the career fair but the button is not working.',
        'category': 'Event Issue',
        'priority': 'medium',
        'status': 'in_progress',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'assignedTo': 'admin_1',
        'responses': [
          {
            'responderId': 'admin_1',
            'responderName': 'Admin User',
            'message':
                'We are investigating this issue. Please try again in a few minutes.',
            'isAdmin': true,
            'timestamp': FieldValue.serverTimestamp(),
          },
        ],
      },
    ];

    for (var ticket in tickets) {
      final docRef = _firestore.collection('supportTickets').doc();
      batch.set(docRef, ticket);
    }
    await batch.commit();
  }

  Future<void> _generateDummyFeedback() async {
    final batch = _firestore.batch();
    final feedback = [
      {
        'userId': 'user_1',
        'userEmail': 'john.doe@strathmore.edu',
        'feedbackType': 'feature_request',
        'message': 'It would be great to have a dark mode option for the app.',
        'rating': 4,
        'category': 'UI/UX',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'reviewedBy': null,
        'reviewedAt': null,
        'adminResponse': null,
      },
      {
        'userId': 'user_2',
        'userEmail': 'jane.smith@strathmore.edu',
        'feedbackType': 'general',
        'message':
            'The app is very helpful for staying organized with campus events.',
        'rating': 5,
        'category': 'UI/UX',
        'status': 'reviewed',
        'createdAt': FieldValue.serverTimestamp(),
        'reviewedBy': 'admin_1',
        'reviewedAt': FieldValue.serverTimestamp(),
        'adminResponse':
            'Thank you for your positive feedback! We\'re glad the app is helping you.',
      },
    ];

    for (var item in feedback) {
      final docRef = _firestore.collection('feedback').doc();
      batch.set(docRef, item);
    }
    await batch.commit();
  }

  Future<void> _generateDummyFAQs() async {
    final batch = _firestore.batch();
    final faqs = [
      {
        'question': 'How do I reset my password?',
        'answer':
            'Go to the login screen and click on "Forgot Password". Enter your email address and follow the instructions sent to your email.',
        'category': 'Account',
        'isActive': true,
        'helpfulCount': 15,
        'notHelpfulCount': 2,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'question': 'How do I register for campus events?',
        'answer':
            'Navigate to the Events section, find the event you want to attend, and click the "Register" button. You\'ll receive a confirmation email.',
        'category': 'Events',
        'isActive': true,
        'helpfulCount': 23,
        'notHelpfulCount': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'question': 'How do I post in the forum?',
        'answer':
            'Go to the Forum section, click "Ask Question" or "New Post", fill in the title and content, select a category, and submit your post.',
        'category': 'Forum',
        'isActive': true,
        'helpfulCount': 8,
        'notHelpfulCount': 3,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var faq in faqs) {
      final docRef = _firestore.collection('faqs').doc();
      batch.set(docRef, faq);
    }
    await batch.commit();
  }

  // --- Notifications (Admin Management) ---
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    required String type,
    String priority = 'medium',
    String? senderId,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': senderId,
    });
  }

  Future<void> sendNotificationToAllStudents({
    required String title,
    required String message,
    required String type,
    String priority = 'medium',
    String? senderId,
  }) async {
    // Get all students
    final studentsSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    final batch = _firestore.batch();
    for (var doc in studentsSnapshot.docs) {
      final notificationRef = _firestore.collection('notifications').doc();
      batch.set(notificationRef, {
        'userId': doc.id,
        'title': title,
        'message': message,
        'type': type,
        'priority': priority,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'senderId': senderId,
      });
    }
    await batch.commit();
  }

  Future<void> sendNotificationToStudentsByCategory({
    required String title,
    required String message,
    required String type,
    String priority = 'medium',
    String? senderId,
    String? category,
  }) async {
    Query query = _firestore
        .collection('users')
        .where('role', isEqualTo: 'student');

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    final studentsSnapshot = await query.get();

    final batch = _firestore.batch();
    for (var doc in studentsSnapshot.docs) {
      final notificationRef = _firestore.collection('notifications').doc();
      batch.set(notificationRef, {
        'userId': doc.id,
        'title': title,
        'message': message,
        'type': type,
        'priority': priority,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'senderId': senderId,
      });
    }
    await batch.commit();
  }

  Future<void> sendNotificationToStudentsByYear({
    required String title,
    required String message,
    required String type,
    String priority = 'medium',
    String? senderId,
    String? year,
  }) async {
    Query query = _firestore
        .collection('users')
        .where('role', isEqualTo: 'student');

    if (year != null && year.isNotEmpty) {
      query = query.where('year', isEqualTo: year);
    }

    final studentsSnapshot = await query.get();

    final batch = _firestore.batch();
    for (var doc in studentsSnapshot.docs) {
      final notificationRef = _firestore.collection('notifications').doc();
      batch.set(notificationRef, {
        'userId': doc.id,
        'title': title,
        'message': message,
        'type': type,
        'priority': priority,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'senderId': senderId,
      });
    }
    await batch.commit();
  }

  // --- Notification Templates ---
  Future<DocumentReference> createNotificationTemplate({
    required String templateName,
    required String title,
    required String message,
    required String type,
    String priority = 'medium',
  }) async {
    final templatesCollection = _firestore.collection('notificationTemplates');
    return await templatesCollection.add({
      'templateName': templateName,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNotificationTemplate(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('notificationTemplates').doc(templateId).update(
      {...data, 'lastUpdated': FieldValue.serverTimestamp()},
    );
  }

  Future<void> deleteNotificationTemplate(String templateId) async {
    await _firestore
        .collection('notificationTemplates')
        .doc(templateId)
        .delete();
  }

  Future<List<Map<String, dynamic>>> getAllNotificationTemplates() async {
    final snapshot = await _firestore.collection('notificationTemplates').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // --- Notification Analytics ---
  Future<Map<String, dynamic>> getNotificationStats() async {
    final totalNotifications = await _firestore
        .collection('notifications')
        .count()
        .get();
    final unreadNotifications = await _firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .count()
        .get();

    return {
      'totalNotifications': totalNotifications.count,
      'unreadNotifications': unreadNotifications.count,
      'readNotifications':
          (totalNotifications.count ?? 0) - (unreadNotifications.count ?? 0),
    };
  }

  Future<List<Map<String, dynamic>>> getRecentNotifications({
    int limit = 10,
  }) async {
    final snapshot = await _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // --- Dashboard and Reporting ---
  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    // Get various statistics for admin dashboard
    final usersCount = await _firestore.collection('users').count().get();
    final studentsCount = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .count()
        .get();
    final eventsCount = await _firestore
        .collection('campusEvents')
        .count()
        .get();
    final activeEventsCount = await _firestore
        .collection('campusEvents')
        .where('eventDate', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .count()
        .get();
    final forumPostsCount = await _firestore
        .collection('questions')
        .count()
        .get();
    final notificationsCount = await _firestore
        .collection('notifications')
        .count()
        .get();
    final unreadNotificationsCount = await _firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .count()
        .get();

    return {
      'totalUsers': usersCount.count,
      'totalStudents': studentsCount.count,
      'totalEvents': eventsCount.count,
      'activeEvents': activeEventsCount.count,
      'totalForumPosts': forumPostsCount.count,
      'totalNotifications': notificationsCount.count,
      'unreadNotifications': unreadNotificationsCount.count,
    };
  }

  Future<Map<String, dynamic>> getStudentDashboardStats(
    String studentId,
  ) async {
    // Get personalized stats for student dashboard
    final userDoc = await _firestore.collection('users').doc(studentId).get();
    final userData = userDoc.data();

    // Get checklist progress
    final checklistDoc = await _firestore
        .collection('onboardingChecklists')
        .doc(studentId)
        .get();
    int completedTasks = 0;
    int totalTasks = 0;
    if (checklistDoc.exists) {
      final checklistData = checklistDoc.data() as Map<String, dynamic>;
      completedTasks = checklistData['completedTasks'] ?? 0;
      totalTasks = checklistData['totalTasks'] ?? 0;
    }

    // Get user's forum posts
    final userPosts = await _firestore
        .collection('questions')
        .where('posterUserID', isEqualTo: studentId)
        .count()
        .get();

    // Get user's notifications
    final userNotifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: studentId)
        .count()
        .get();

    // Get upcoming events
    final upcomingEvents = await _firestore
        .collection('campusEvents')
        .where('eventDate', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('eventDate')
        .limit(5)
        .get();

    return {
      'userName': userData?['fullName'] ?? 'Student',
      'userEmail': userData?['email'] ?? '',
      'checklistProgress': totalTasks > 0
          ? (completedTasks / totalTasks) * 100
          : 0,
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'forumPosts': userPosts.count,
      'notifications': userNotifications.count,
      'upcomingEvents': upcomingEvents.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList(),
    };
  }

  Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 10}) async {
    // Get recent activity across the system
    final activities = <Map<String, dynamic>>[];

    // Recent forum posts
    final recentPosts = await _firestore
        .collection('questions')
        .orderBy('timestamp', descending: true)
        .limit(limit ~/ 3)
        .get();

    for (var doc in recentPosts.docs) {
      final data = doc.data();
      activities.add({
        'type': 'forum_post',
        'title': 'New forum post: ${data['title']}',
        'description': data['postContent'] ?? '',
        'timestamp': data['timestamp'],
        'userEmail': data['posterEmail'] ?? '',
      });
    }

    // Recent events
    final recentEvents = await _firestore
        .collection('campusEvents')
        .orderBy('eventDate', descending: true)
        .limit(limit ~/ 3)
        .get();

    for (var doc in recentEvents.docs) {
      final data = doc.data();
      activities.add({
        'type': 'event',
        'title': 'New event: ${data['eventName']}',
        'description': data['description'] ?? '',
        'timestamp': data['eventDate'],
        'organizer': data['organizer'] ?? '',
      });
    }

    // Recent notifications
    final recentNotifications = await _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(limit ~/ 3)
        .get();

    for (var doc in recentNotifications.docs) {
      final data = doc.data();
      activities.add({
        'type': 'notification',
        'title': 'Notification: ${data['title']}',
        'description': data['message'] ?? '',
        'timestamp': data['timestamp'],
        'priority': data['priority'] ?? 'medium',
      });
    }

    // Sort by timestamp and return
    activities.sort(
      (a, b) =>
          (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp),
    );
    return activities.take(limit).toList();
  }

  Future<Map<String, dynamic>> getForumEngagementStats() async {
    final totalPosts = await _firestore.collection('questions').count().get();
    final totalReplies = await _firestore
        .collectionGroup('replies')
        .count()
        .get();

    // Get posts by type/category
    final academicPosts = await _firestore
        .collection('questions')
        .where('category', isEqualTo: 'Academic')
        .count()
        .get();

    final generalPosts = await _firestore
        .collection('questions')
        .where('category', isEqualTo: 'General')
        .count()
        .get();

    return {
      'totalPosts': totalPosts.count,
      'totalReplies': totalReplies.count,
      'academicPosts': academicPosts.count,
      'generalPosts': generalPosts.count,
      'engagementRate': (totalPosts.count ?? 0) > 0
          ? ((totalReplies.count ?? 0) / (totalPosts.count ?? 1))
          : 0,
    };
  }

  Future<Map<String, dynamic>> getChecklistCompletionStats() async {
    final checklists = await _firestore
        .collection('onboardingChecklists')
        .get();
    int totalStudents = 0;
    int completedStudents = 0;
    int totalTasks = 0;
    int completedTasks = 0;

    for (var doc in checklists.docs) {
      final data = doc.data();
      totalStudents++;
      totalTasks += (data['totalTasks'] ?? 0) is int
          ? (data['totalTasks'] ?? 0) as int
          : ((data['totalTasks'] ?? 0) as num).toInt();
      completedTasks += (data['completedTasks'] ?? 0) is int
          ? (data['completedTasks'] ?? 0) as int
          : ((data['completedTasks'] ?? 0) as num).toInt();

      if ((data['completedTasks'] ?? 0) >= (data['totalTasks'] ?? 0)) {
        completedStudents++;
      }
    }

    return {
      'totalStudents': totalStudents,
      'completedStudents': completedStudents,
      'completionRate': totalStudents > 0
          ? (completedStudents / totalStudents) * 100
          : 0,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'taskCompletionRate': totalTasks > 0
          ? (completedTasks / totalTasks) * 100
          : 0,
    };
  }

  Future<List<Map<String, dynamic>>> getUserActivityLogs({
    int limit = 50,
  }) async {
    // This would typically come from a separate activity logs collection
    // For now, we'll generate some sample data
    final logs = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < limit; i++) {
      logs.add({
        'userId': 'user_${i % 10}',
        'action': _getRandomAction(),
        'timestamp': Timestamp.fromDate(now.subtract(Duration(hours: i))),
        'details': 'User performed ${_getRandomAction()}',
      });
    }

    return logs;
  }

  String _getRandomAction() {
    final actions = [
      'login',
      'forum_post',
      'event_view',
      'checklist_update',
      'notification_read',
    ];
    return actions[DateTime.now().millisecond % actions.length];
  }

  // --- Dummy Data Generation ---
  Future<void> generateDummyData() async {
    await _generateDummyUsers();
    await _generateDummyEvents();
    await _generateDummyForumPosts();
    await _generateDummyNotifications();
    await _generateDummyChecklists();
  }

  Future<void> _generateDummyUsers() async {
    final batch = _firestore.batch();
    final users = [
      {
        'fullName': 'John Doe',
        'email': 'john.doe@strathmore.edu',
        'role': 'student',
      },
      {
        'fullName': 'Jane Smith',
        'email': 'jane.smith@strathmore.edu',
        'role': 'student',
      },
      {
        'fullName': 'Mike Johnson',
        'email': 'mike.johnson@strathmore.edu',
        'role': 'student',
      },
      {
        'fullName': 'Sarah Wilson',
        'email': 'sarah.wilson@strathmore.edu',
        'role': 'student',
      },
      {
        'fullName': 'David Brown',
        'email': 'david.brown@strathmore.edu',
        'role': 'student',
      },
    ];

    for (var user in users) {
      final docRef = _firestore.collection('users').doc();
      batch.set(docRef, {...user, 'createdAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }

  Future<void> _generateDummyEvents() async {
    final batch = _firestore.batch();
    final events = [
      {
        'eventName': 'Career Fair 2024',
        'description': 'Annual career fair with top companies',
        'eventDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
        'eventTime': '9:00 AM - 5:00 PM',
        'locationID': 'main_auditorium',
        'organizer': 'Career Services',
      },
      {
        'eventName': 'Student Leadership Workshop',
        'description': 'Workshop on developing leadership skills',
        'eventDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
        'eventTime': '2:00 PM - 4:00 PM',
        'locationID': 'room_201',
        'organizer': 'Student Affairs',
      },
      {
        'eventName': 'Tech Innovation Summit',
        'description': 'Showcase of student tech projects',
        'eventDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 14)),
        ),
        'eventTime': '10:00 AM - 6:00 PM',
        'locationID': 'innovation_center',
        'organizer': 'Computer Science Department',
      },
    ];

    for (var event in events) {
      final docRef = _firestore.collection('campusEvents').doc();
      batch.set(docRef, event);
    }
    await batch.commit();
  }

  Future<void> _generateDummyForumPosts() async {
    final batch = _firestore.batch();
    final posts = [
      {
        'posterUserID': 'user_1',
        'posterEmail': 'john.doe@strathmore.edu',
        'title': 'Best study spots on campus?',
        'postContent':
            'Looking for quiet places to study. Any recommendations?',
        'category': 'General',
        'upvotes': 5,
        'downvotes': 0,
        'isPinned': false,
        'isFlagged': false,
        'flagCount': 0,
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'posterUserID': 'user_2',
        'posterEmail': 'jane.smith@strathmore.edu',
        'title': 'Computer Science Assignment Help',
        'postContent':
            'Stuck on the algorithms assignment. Anyone willing to help?',
        'category': 'Academic',
        'upvotes': 3,
        'downvotes': 1,
        'isPinned': false,
        'isFlagged': false,
        'flagCount': 0,
        'timestamp': FieldValue.serverTimestamp(),
      },
    ];

    for (var post in posts) {
      final docRef = _firestore.collection('questions').doc();
      batch.set(docRef, post);
    }
    await batch.commit();
  }

  Future<void> _generateDummyNotifications() async {
    final batch = _firestore.batch();
    final notifications = [
      {
        'userId': 'user_1',
        'title': 'Welcome to Strathmore!',
        'message':
            'Welcome to your first semester. Complete your onboarding checklist.',
        'type': 'general',
        'priority': 'high',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'user_2',
        'title': 'Career Fair Reminder',
        'message': 'Don\'t forget the career fair this Friday!',
        'type': 'event',
        'priority': 'medium',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      },
    ];

    for (var notification in notifications) {
      final docRef = _firestore.collection('notifications').doc();
      batch.set(docRef, notification);
    }
    await batch.commit();
  }

  Future<void> _generateDummyChecklists() async {
    final batch = _firestore.batch();
    final checklists = [
      {
        'studentID': 'user_1',
        'templateName': 'Freshman Orientation Checklist',
        'tasks': [
          {'description': 'Get Student ID Card', 'isCompleted': true},
          {'description': 'Register for Classes', 'isCompleted': true},
          {'description': 'Attend Orientation', 'isCompleted': false},
          {'description': 'Set up Email', 'isCompleted': true},
        ],
        'completedTasks': 3,
        'totalTasks': 4,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      },
      {
        'studentID': 'user_2',
        'templateName': 'Freshman Orientation Checklist',
        'tasks': [
          {'description': 'Get Student ID Card', 'isCompleted': true},
          {'description': 'Register for Classes', 'isCompleted': false},
          {'description': 'Attend Orientation', 'isCompleted': false},
          {'description': 'Set up Email', 'isCompleted': false},
        ],
        'completedTasks': 1,
        'totalTasks': 4,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      },
    ];

    for (var checklist in checklists) {
      final docRef = _firestore
          .collection('onboardingChecklists')
          .doc(checklist['studentID'] as String);
      batch.set(docRef, checklist);
    }
    await batch.commit();
  }

  // --- Onboarding Checklist (Shared Template Model) ---
  Future<Map<String, dynamic>?> getActiveChecklistTemplate() async {
    final snapshot = await _firestore
        .collection('checklistTemplates')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return {'id': snapshot.docs.first.id, ...snapshot.docs.first.data()};
  }

  Future<List<int>> getStudentChecklistProgress(String studentId) async {
    final doc = await _firestore
        .collection('onboardingProgress')
        .doc(studentId)
        .get();
    if (!doc.exists) return [];
    final data = doc.data();
    return List<int>.from(data?['completedTaskIndexes'] ?? []);
  }

  Future<void> setStudentChecklistProgress(
    String studentId,
    List<int> completedTaskIndexes,
  ) async {
    await _firestore.collection('onboardingProgress').doc(studentId).set({
      'completedTaskIndexes': completedTaskIndexes,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
